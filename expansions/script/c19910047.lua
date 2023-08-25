--Le Medivatale Wolfer
function c160008799.initial_effect(c)
	c:EnableCounterPermit(0x88)
	--link summon
	aux.AddLinkProcedure(c,c160008799.matfilter,2,2)
	c:EnableReviveLimit()
	--Evolute
	   local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,160008799)
	--e1:SetCondition(c160008799.condition)
	e1:SetCost(c160008799.cost)
	e1:SetTarget(c160008799.target)
	e1:SetOperation(c160008799.operation)
	c:RegisterEffect(e1)
--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,160008800)
	e2:SetCondition(c160008799.spcon)
	e2:SetTarget(c160008799.sptg)
	e2:SetOperation(c160008799.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function c160008799.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c160008799.filter(c,e,tp)
	return  c:IsSetCard(0xab5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c160008799.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c160008799.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c160008799.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c160008799.spop(e,tp,eg,ep,ev,re,r,rp)
   if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c160008799.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	end
end
function c160008799.matfilter(c)
	return c:IsSetCard(0xab5)
end
function c160008799.hhfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab5) and c:IsType(TYPE_EVOLUTE) and c:IsCanAddCounter(0x88,3)
end
function c160008799.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c160008799.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c160008799.hhfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(160008799,1))
	Duel.SelectTarget(tp,c160008799.hhfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function c160008799.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddEC(3)~=0 then
		end
	end