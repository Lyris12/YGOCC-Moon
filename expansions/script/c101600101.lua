--Monument of the Signer Dragon
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetLabel(0)
	e1:SetCost(cid.cost1)
	e1:SetTarget(cid.target1)
	e1:SetOperation(cid.activate1)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(cid.target2)
	e2:SetOperation(cid.activate2)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	--Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--ACTIVATE 1
function cid.filter1(c,e,tp,c1,c2,lv)
	local g=(c1 and c2) and Group.FromCards(c1,c2) or nil
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xcd01) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and c:IsLevel(lv)
end
function cid.cfilter1(c,e,tp,mode)
	local fcheck=(mode==0) and c:IsAbleToRemoveAsCost() or (c:IsFaceup() and c:IsAbleToDeck())
	local loc=(mode==0) and LOCATION_GRAVE or LOCATION_REMOVED
	local selection=(mode==0) and Duel.IsExistingMatchingCard(cid.cfilter2,tp,loc,0,1,c,e,tp,mode,c,c:GetLevel()) or Duel.IsExistingTarget(cid.cfilter2,tp,loc,0,1,c,e,tp,mode,c,c:GetLevel())
	return c:IsType(TYPE_TUNER) and fcheck and c:IsSetCard(0xcd01) and c:GetLevel()>0 and selection
end
function cid.cfilter2(c,e,tp,mode,c1,lv)
	local fcheck=(mode==0) and c:IsAbleToRemoveAsCost() or (c:IsFaceup() and c:IsAbleToDeck())
	return not c:IsType(TYPE_TUNER) and fcheck and c:IsSetCard(0xcd01) and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_EXTRA,0,1,Group.FromCards(c,c1),e,tp,c1,c,lv+c:GetLevel())
end
function cid.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and Duel.IsExistingMatchingCard(cid.cfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,cid.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,0)
	if not g1:GetFirst() then return end
	local lv=g1:GetFirst():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,cid.cfilter2,tp,LOCATION_GRAVE,0,1,1,g1,e,tp,0,g1:GetFirst(),lv)
	if not g2:GetFirst() then return end
	lv=lv+g2:GetFirst():GetLevel()
	g1:Merge(g2)
	if #g1==2 then
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
		Duel.SetTargetParam(lv)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function cid.activate1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,nil,lv):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
--ACTIVATE 2
function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and Duel.IsExistingTarget(cid.cfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,cid.cfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,1)
	if not g1:GetFirst() then return end
	local lv=g1:GetFirst():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,cid.cfilter2,tp,LOCATION_REMOVED,0,1,1,g1,e,tp,1,g1:GetFirst(),lv)
	if not g2:GetFirst() then return end
	g1:Merge(g2)
	Duel.SetTargetParam(lv)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.activate2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g<=1 then return end
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 then
		if g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=#g then return end
		for i=0,1 do
			if g:Filter(Card.IsControler,nil,i):FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then
				Duel.ShuffleDeck(i)
			end
		end
		local lv=g:GetSum(Card.GetLevel)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,nil,lv):GetFirst()
		if tc then
			Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
--SEARCH
function cid.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsSetCard(0xcd01)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
