--Steinitz’s Flora
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(cod.spcon)
    c:RegisterEffect(e1)
	--Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(cod.cost)
	e2:SetTarget(cod.target)
	e2:SetOperation(cod.operation)
	c:RegisterEffect(e2)
end
function cod.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x63d0) and c:IsType(TYPE_SPIRIT)
end
function cod.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
        Duel.IsExistingMatchingCard(cod.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function cod.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x63d0) and c:IsAbleToGrave()
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_EXTRA_SET_COUNT)
        c:RegisterEffect(e2)
	end
end