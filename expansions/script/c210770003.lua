--Labyrinth Spider
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,25955164,62340868,98434877,210770012)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
    --disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.distg)
    e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
    --Move
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.con)
	c:RegisterEffect(e4)
end
function s.atkfilter(c)
	return c:IsFaceup() and (c:IsCode(25955164,62340868,98434877,25833572) or aux.IsCodeListed(c,25955164,62340868,98434877))
end
function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end

function s.distg(e,c)
    local g=e:GetHandler():GetColumnGroup()
    return g:IsContains(c) and c:GetAttack()<e:GetHandler():GetAttack()
end

--function s.filter(c)
--    return c:GetSequence()>4
--end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local seq=e:GetHandler():GetSequence()
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,zone)
	e:SetLabel(math.log(zone,2))
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
    local tc=Duel.GetFieldCard(tp,LOCATION_MZONE,zone)
    if tc then
        Duel.SwapSequence(c,tc)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        Duel.MoveSequence(c,zone)
    end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210770012),tp,LOCATION_FZONE,0,1,nil)
end