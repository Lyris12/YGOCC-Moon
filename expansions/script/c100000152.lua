--[[
Crystarion Ascendant - Pillar of Cobalt
Cristarione Ascendente - Pilastro di Cobalto
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[You can discard this card; add 1 "Crystarion" Drive Monster and 1 "Crystarion" Ritual Monster from your Deck and/or GY to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,aux.DiscardSelfCost,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--[[If this card is in your GY (Quick Effect): You can Ritual Summon 1 "Crystarion" Ritual Monster from your hand or GY, by reducing the Energy of your Engaged "Crystarion" Drive Monster
	by an amount equal to the Level of the Ritual Monster you Ritual Summon, and if you do, shuffle this card into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e2:SetCustomCategory(CATEGORY_UPDATE_ENERGY|CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,nil,s.rttg,s.rtop)
	c:RegisterEffect(e2)
end
--E1
function s.filter1(c,tp,type)
	return c:IsSetCard(ARCHE_CRYSTARION) and c:IsMonster(type) and c:IsAbleToHand()
		and (not tp or Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c,nil,TYPE_RITUAL))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,TYPE_DRIVE) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.filter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp,TYPE_DRIVE)
	if #g1==0 then return end
	local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.filter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,g1,nil,TYPE_RITUAL)
	if #g2==0 then return end
	g1:Merge(g2)
	if #g1==2 then
		Duel.Search(g1,tp)
	end
end

--E2
function s.rtfilter(c,e,tp,en)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_CRYSTARION) and c:HasLevel()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) and en:IsCanUpdateEnergy(-c:GetLevel(),tp,REASON_EFFECT,e)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION) and c:IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,en)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,en,1,INFOFLAG_DECREASE,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local en=Duel.GetEngagedCard(tp)
	if not (en and en:IsMonster(TYPE_DRIVE) and en:IsSetCard(ARCHE_CRYSTARION)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.Necro(s.rtfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,en)
	local tc=tg:GetFirst()
	if tc then
		local c=e:GetHandler()
		en:UpdateEnergy(-tc:GetLevel(),tp,REASON_EFFECT,true,c,e)
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			if c:IsRelateToChain() then
				Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end