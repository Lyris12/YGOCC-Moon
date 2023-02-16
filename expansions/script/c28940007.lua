--Gardrenial Spirits - Arrange
local ref,id=GetID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),true)
	--QuickFusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(ref.fuscost)
	e1:SetTarget(ref.fustg)
	e1:SetOperation(ref.fusop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(ref.settg)
	e2:SetOperation(ref.setop)
	c:RegisterEffect(e2)
end

function ref.fusmatfilter(c,e,tp)
	return c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function ref.fusfilter(c,e,tp,mc)
	return Gardrenial.Is(c) and c:IsType(TYPE_FUSION)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function ref.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function ref.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.fusmatfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp)
		and Duel.GetFlagEffect(tp,id)==0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g=Duel.SelectMatchingCard(tp,ref.fusmatfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,ref.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g:GetFirst())
		if #g2>0 then
			local fc=g2:GetFirst()
			fc:SetMaterial(g)
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,1,2,1) end
		end
	end
end

--Search
function ref.setfilter(c,e,tp)
	return Gardrenial.Is(c)
		and ((c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable())
		or (c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)))
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function ref.setop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else Duel.SSet(tp,tc) end
	end
end
