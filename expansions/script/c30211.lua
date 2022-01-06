--Mantra Seed
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	c:EnableReviveLimit()
	--Cannot be Summoned/Set
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPSUMMON)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e4)
	--SS from anywhere
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCondition(scard.spcon)
	e0:SetTarget(scard.sptg)
	e0:SetOperation(scard.spop)
	e0:SetCountLimit(1,s_id)
	c:RegisterEffect(e0)
	--Protect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81994591,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(scard.con)
	e4:SetCost(scard.indcost)
	e4:SetOperation(scard.indop)
	e4:SetCountLimit(1,s_id+10000)
	c:RegisterEffect(e4)
end
function scard.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ((e:GetHandler():IsReason(REASON_EFFECT)) or e:GetHandler():IsReason(REASON_COST))
	and re:IsHasType(0xFFD)
		and re:GetHandler():IsMantra()
end
function scard.filter(c,e,tp)
	return c:IsMantra() and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,scard.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
function scard.indfil(c)
	return c:IsMantra() and c:IsFaceup()
end
function scard.con(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and Duel.IsExistingMatchingCard(scard.indfil,tp,LOCATION_MZONE,0,1,nil)
end
function scard.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function scard.indop(e,tp,eg,ep,ev,re,r,rp)
	--undestroy
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(scard.profilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	--untarget
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(scard.rcon)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(scard.profilter)
	Duel.RegisterEffect(e2,true)
end
function scard.profilter(e,tp,eg,ep,ev,re,r,rp)
	return aux.TargetBoolFunction(Card.IsMantra)
end
function scard.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
