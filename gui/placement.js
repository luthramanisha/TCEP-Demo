var placement = {}
var transitions = []
var previousPlacement = []
var transitionMode = null
var transitionTime = null

const isMemberKnown = (member) => Object.keys(placement).indexOf(member.host) !== -1

const addUpMember = (member) => {
    var memberName = member.host.replace('app', 'cluster')
    member.host = memberName
    if (!isMemberKnown(member)) {
        placement[memberName] = {
            operators: [],
            usage: 0
        }
        previousPlacement[memberName] = {
            operators: [],
            usage: 0
        }
        return
    }
    console.log('Ignoring already known member ' + memberName)
}

const setOperator = (mode, oldMember, oldOperator, member, operator) => {
    if (mode) {
        transitionMode = mode;
    }

    var memberName = member.host.replace('app', 'cluster')
    member.host = memberName
    if (!isMemberKnown(member)) {
        addUpMember(member)
        console.log(`Adding member that was previously unknown ${member.host}`)
    }
    var isTransition = false
    if (oldMember && oldOperator) {
        // TRANSITION
        // remove old operator from original host
        var oldMemberName = oldMember.host.replace('app', 'cluster')
        placement[oldMemberName].operators = placement[oldMemberName].operators.filter(op => {
            return oldOperator.name !== op.name
        });
        if (placement[oldMemberName].operators.length === 0) {
            placement[oldMemberName].usage = 2
        }
        transitions.push({source: oldMemberName, target: memberName})
        isTransition = true
    }

    let known = false
    let previousKnown = false
    for (let index in placement[memberName].operators) {
        const op = placement[memberName].operators[index]
        if (operator.name === op.name) {
            console.log('Placement already known, skipping')
            known = true
            break
        }
    }
    for (let index in previousPlacement[memberName].operators) {
        const op = previousPlacement[memberName].operators[index]
        if (operator.name === op.name) {
            console.log('Placement previously already known, skipping')
            previousKnown = true
            break
        }
    }
    if (!known) {
        placement[memberName].operators.push(operator)
        placement[memberName].usage = 1
    }
    if (!previousKnown && !isTransition) {
        previousPlacement[memberName].operators.push(operator)
    }
}

const setTransitionTime = (time) => {
    transitionTime = time
}

const getPlacement = () => placement
const getPreviousPlacement = () => previousPlacement
const getTransitions = () => transitions
const getTransitionMode = () => transitionMode
const getTransitionTime = () => transitionTime
const clear = () => {placement = {}, transitions = [], previousPlacement = {}, transitionMode = null, transitionTime = null}

module.exports = {
    addUpMember,
    setOperator,
    setTransitionTime,
    getPlacement,
    getPreviousPlacement,
    getTransitions,
    getTransitionMode,
    getTransitionTime,
    clear,
}