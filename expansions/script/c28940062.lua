--Studies In Elemergence
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	--c:SetUniqueOnField(LOCATION_ONFIELD,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(ref.fustg)
	e1:SetOperation(ref.fusop)
	c:RegisterEffect(e1)
	--GY Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCost(ref.actcost)
	e2:SetTarget(ref.acttg)
	e2:SetOperation(ref.actop)
	c:RegisterEffect(e2)
end

--Fusion
function ref.tdfilter(c,e,tp,mg)
	local g=mg:Clone()
	g:RemoveCard(c)
	return Elemerge.Is(c) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function ref.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and Elemerge.Is(c) and c:CheckFusionMaterial(mg,nil,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function ref.elefilter(c)
	return Elemerge.Is(c) and c:IsType(TYPE_MONSTER)
end
function ref.matfilter(c) return c:IsFaceup() and c:IsAbleToDeck() end
function ref.fustg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return Elemerge.Is(chkc) and chkc:IsAbleToDeck() end
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Card.IsAbleToDeck,nil)
	mg:Merge(Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil))
	local g=mg:Filter(ref.elefilter,nil)
	local mc=g:GetFirst()
	while mc do
		mc:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_ALL)
		mc:AssumeProperty(ASSUME_RACE,RACE_ALL)
		mc=g:GetNext()
	end
	if chk==0 then
		return Duel.IsExistingTarget(ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,e,tp,mg) --Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil,e,tp,mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetFirstTarget()
	if dc and dc:IsRelateToEffect(e) and Duel.SendtoDeck(dc,nil,2,REASON_EFFECT) then
		local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Card.IsAbleToDeck,nil)
		mg:Merge(Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil))
		local g=mg:Filter(ref.elefilter,nil)
		local mc=g:GetFirst()
		while mc do
			mc:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_ALL)
			mc:AssumeProperty(ASSUME_RACE,RACE_ALL)
			mc=g:GetNext()
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local fg=Duel.SelectMatchingCard(tp,ref.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
		if #fg>0 then
			local fc=fg:GetFirst()
			local mats=Duel.SelectFusionMaterial(tp,fc,mg,c,tp)
			fc:SetMaterial(mats)
			Duel.ConfirmCards(1-tp,mats:Filter(Card.IsLocation,nil,LOCATION_HAND))
			Duel.SendtoDeck(mats,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function ref.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	Duel.PayLPCost(tp,600)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
