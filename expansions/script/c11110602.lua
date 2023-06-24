--Goldie, Metalurgos Maintenance
--Goldie, Metalurgo Manutenzione
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,8)
	--[[▼ [-4]: You can target 1 "Metalurgos" card you control and 1 "Metalurgos" Bigbang Monster in your GY; Destroy the first target, and if you do, Special Summon the second target.]]
	c:DriveEffect(-4,0,CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--[[[OD]: You can Special Summon 1 "Metalurgos" Bigbang Monster from your Extra Deck,
	with a Level equal to or less than twice the number of "Metalurgos" Continuous Spells with different original names on your field and in your GY. (This is treated as a Bigbang Summon.)]]
	c:OverDriveEffect(1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.bbtg,
		s.bbop
	)
	--[[If this card is Normal Summoned: You can add 1 "Metalurgos Conduction" from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	--[[If this card is Drive Summoned: You can target 1 card your opponent controls; destroy it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.DriveSummonedCond)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--FILTERS DE1
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_METALURGOS) and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_BIGBANG) and c:IsSetCard(ARCHE_METALURGOS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--DE1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp)
	end	
	local g1=Duel.Select(HINTMSG_DESTROY,true,tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	if #g1>0 then
		g1:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
		Duel.SetCardOperationInfo(g1,CATEGORY_DESTROY)
	end
	local g2=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,g1,e,tp)
	if #g2>0 then
		Duel.SetCardOperationInfo(g2,CATEGORY_SPECIAL_SUMMON)
	end
	g1:Merge(g2)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==0 then return end
	local tc1=g:Filter(Card.HasFlagEffect,nil,id):GetFirst()
	if tc1 and tc1:IsFaceup() and tc1:IsSetCard(ARCHE_METALURGOS) and Duel.Destroy(tc1,REASON_EFFECT)>0 then
		g:RemoveCard(tc1)
		local tc2=g:GetFirst()
		if tc2 and Duel.GetMZoneCount(tp)>0 then
			Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--FILTERS DE2
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSpell(TYPE_CONTINUOUS) and c:IsSetCard(ARCHE_METALURGOS)
end
function s.bbfilter(c,e,tp,ct)
	return c:IsMonster(TYPE_BIGBANG) and c:IsSetCard(ARCHE_METALURGOS) and c:IsLevelBelow(ct)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false)
end
--DE2
function s.bbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sg=Duel.Group(s.cfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
		if #sg<=0 then return false end
		local ct=sg:GetClassCount(Card.GetOriginalCodeRule)
		return Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ct*2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.bbop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.Group(s.cfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	local ct=sg:GetClassCount(Card.GetOriginalCodeRule)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.bbfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct*2)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end

--FILTERS ME1
function s.filter(c)
	return c:IsCode(CARD_METALURGOS_CONDUCTION) and c:IsAbleToHand()
end
--ME1
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

--ME2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end