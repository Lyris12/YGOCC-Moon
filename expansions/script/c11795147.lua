--Duelahan Outfit - Isle Chieftain
local cid,id=GetID()
function cid.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cid.spcon)
	e1:SetValue(cid.spval)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	--cannot target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(cid.indestg)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(cid.indescon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(cid.indestg)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetCondition(cid.indescon)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x684) and c:IsType(TYPE_LINK)
end
function cid.checkzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function cid.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=cid.checkzone(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function cid.spval(e,c)
	local tp=c:GetControler()
	local zone=cid.checkzone(tp)
	return 0,zone
end
function cid.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x684) and c:IsType(TYPE_LINK) and c:GetSequence()>4
end
function cid.indescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function cid.indestg(e,c)
	return c:IsSetCard(0x684) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end