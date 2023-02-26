--Zero HERO Infernal Lady

local scard,s_id=GetID()
function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DAMAGE|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS|TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetCondition(aux.ExceptOnDamageCalc)
	e1:SetTarget(scard.damtg)
	e1:SetOperation(scard.damop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(scard.spcost)
	e2:SetTarget(scard.sptg)
	e2:SetOperation(scard.spop)
	e2:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e2)
end
function scard.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
function scard.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetMatchingGroupCount(scard.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	if chk==0 then return dam>0 end
	local c=e:GetHandler()
	local p,loc=c:GetControler(),c:GetLocation()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,p,loc,dam)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,c,1,p,loc,dam)
end
function scard.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetMatchingGroupCount(scard.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	if dam<0 then dam=0 end
	local dam=Duel.Damage(1-tp,dam,REASON_EFFECT)
	if dam>0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE)
		e1:SetValue(dam)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end

function scard.spfilter(c)
	return c:IsMonster() and c:IsZHERO() and c:IsAbleToRemoveAsCost()
end
function scard.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(scard.spfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,scard.spfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
