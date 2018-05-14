import TensorSwift

func buildPartWithScoreQueue(
    scoreThreshold: Float32, localMaximumRadius: Int,
    scores: Tensor) -> Queue<PartWithScore> {
    
    var queue = Queue<PartWithScore>()
    
    let height = scores.shape.dimensions[0].value
    let width = scores.shape.dimensions[1].value
    let numKeypoints = scores.shape.dimensions[2].value
    
    for heatmapY in 0..<height {
        for heatmapX in 0..<width {
            for keypointId in 0..<numKeypoints {
                
                let score = scores[heatmapY,heatmapX,keypointId]
                if (score < scoreThreshold) {
                    continue
                }
                
                if (scoreIsMaximumInLocalWindow(
                    keypointId, score, heatmapY, heatmapX, localMaximumRadius, scores)) {
                    queue.enqueue(
                        PartWithScore(score: score,
                                      part: Part(heatmapX: heatmapX, heatmapY: heatmapY, id: keypointId))
                    )
                }
            }
        }
    }
    return queue
}

func scoreIsMaximumInLocalWindow(
    _ keypointId: Int,_ score: Float32,_ heatmapY: Int,_ heatmapX: Int,
    _ localMaximumRadius: Int,_ scores: Tensor) -> Bool {
    let height = scores.shape.dimensions[0].value
    let width = scores.shape.dimensions[1].value
    
    var localMaximum = true
    let yStart = max(heatmapY - localMaximumRadius, 0)
    let yEnd = min(heatmapY + localMaximumRadius + 1, height)
    for yCurrent in yStart..<yEnd {
        let xStart = max(heatmapX - localMaximumRadius, 0)
        let xEnd = min(heatmapX + localMaximumRadius + 1, width)
        for xCurrent in xStart..<xEnd {
            if (scores[yCurrent,xCurrent,keypointId] > score) {
                localMaximum = false
                break
            }
        }
        if (!localMaximum) {
            break
        }
    }
    return localMaximum
}