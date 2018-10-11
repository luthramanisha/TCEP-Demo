const express = require('express')
const router = express.Router()
const Placement = require('./placement')

router.get('/data', (req, res) => {
    const placement = Placement.getPlacement()
    const previousPlacement = Placement.getPreviousPlacement()
    const transitions = Placement.getTransitions()
    const transitionMode = Placement.getTransitionMode()
    const transitionTime = Placement.getTransitionTime()
    const nodes = []
    const previousNodes = []
    for (let key in placement) {
        nodes.push({
            name: key,
            operators: placement[key].operators,
            usage: placement[key].usage
        })
    }
    for (let key in previousPlacement) {
        previousNodes.push({
            name: key,
            operators: previousPlacement[key].operators,
            usage: previousPlacement[key].usage
        })
    }
    res.send({ nodes, previousNodes, transitions, transitionMode, transitionTime })
});

router.post('/setOperator', (req, res) => {
    Placement.setOperator(req.body.transitionMode, req.body.oldMember, req.body.oldOperator, req.body.member, req.body.operator)
    res.send({})
});

router.post('/setMembers', (req, res) => {
    req.body.members.forEach((member) => Placement.addUpMember(member))
    res.send({})
});

router.post('/setTransitionTime', (req, res) => {
    Placement.setTransitionTime(req.body.time)
    res.send({})
})

router.delete('/data', (req, res) => {
    Placement.clear()
    res.send({})
})

router.get('/', (req, res) => {
    res.sendFile('graph.html', { root : __dirname})
})

router.use('/resources', express.static(__dirname + '/resources'));

module.exports = router