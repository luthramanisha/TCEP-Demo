var placement = {}
var transitions = []
var transitionMode = null

const isMemberKnown = (member) => Object.keys(placement).indexOf(member.host) !== -1

const addUpMember = (member) => {
    var memberName = member.host.replace('app', 'cluster')
    member.host = memberName
    if (!isMemberKnown(member)) {
        placement[memberName] = {
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
    }

    
    for (let index in placement[memberName].operators) {
        const op = placement[memberName].operators[index]
        if (operator.name === op.name) {
            console.log('Placement already known, skipping')
            return
        }
    }
    placement[memberName].operators.push(operator)
    placement[memberName].usage = 1
}

const getPlacement = () => placement
const getTransitions = () => transitions
const getTransitionMode = () => transitionMode
const clear = () => {placement = {}, transitions = []}

module.exports = {
    addUpMember,
    setOperator,
    getPlacement,
    getTransitions,
    getTransitionMode,
    clear,
}