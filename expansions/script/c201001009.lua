--I.I.I. Hemiptank
local cid,id=GetID()
function cid.initial_effect(c)
	--double tribute
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e1:SetValue(cid.condition)
    c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(cid.spcon)
	c:RegisterEffect(e2)
	--destruction immune
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_RELEASE)
    e8:SetProperty(EFFECT_FLAG_DELAY)
    e8:SetCountLimit(1,id)
    e8:SetOperation(cid.operation)
	c:RegisterEffect(e8)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(cid.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdbd)
end
function cid.condition(e,c)
     return c:IsSetCard(0xdbd)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cid.inestg)
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.indestg(e,c)
    return c:IsSetCard(0xdbd) or c:IsCode(35052053)
end