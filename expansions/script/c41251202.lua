--Daylilly Viburnum
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddDaylillyFusionProcedures(c)
	--random shuffle
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT(true)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--spsummon
	aux.AddDaylillySpSummonEffect(c)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e3:SetLabel(0)
	e3:SetCondition(aux.ExceptOnDamageCalc)
	e3:SetCost(aux.DummyCost)
	e3:SetTarget(s.dtg)
	e3:SetOperation(s.dop)
	c:RegisterEffect(e3)
	--place in pzone
	Auxiliary.AddDaylillyPlacingEffect(c)
end
--E1
function s.cfilter1(c,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and (c:IsFaceup() or c:IsControler(tp))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.cfilter1,nil,tp)
	if chk==0 then return #g1>0 end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local sg=g1:Select(tp,1,1,nil)
	local exg=sg:Filter(Auxiliary.ExtraReleaseFilter,nil,tp)
	for ec in Auxiliary.Next(exg) do
		local te=ec:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
		if te and (not g2:IsContains(ec) or Duel.SelectYesNo(tp,STRING_ASK_EXTRA_RELEASE_NONSUM)) then
			te:UseCountLimit(tp)
		end
	end
	Duel.Release(sg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	if chk==0 then return #g>0 and g:IsExists(Card.IsAbleToDeck,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,PLAYER_ALL,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND):IsExists(Card.IsAbleToDeck,1,nil) then return end
	local hands={Duel.GetHand(0),Duel.GetHand(1)}
	if #hands[1]>0 or #hands[1]>0 then
		local opt=aux.Option(tp,nil,nil,{#hands[tp+1]>0,id,4},{#hands[2-tp]>0,id,5})
		local p = (opt==0) and tp or 1-tp
		local sg=hands[p+1]:RandomSelect(tp,1)
		if #sg>0 then
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

function s.cfilter3(c)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and c:GetTextAttack()>0
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		if not e:IsCostChecked() or #g<=0 then return false end
		return Duel.CheckReleaseGroup(tp,s.cfilter3,1,nil)
	end
	local rg=Duel.SelectReleaseGroup(tp,s.cfilter3,1,1,nil)
	Duel.Release(rg,REASON_COST)
	local atk=rg:GetFirst():GetTextAttack()
	e:SetLabel(atk)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-atk)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local atk=e:GetLabel()
		for tc in aux.Next(g) do
			tc:UpdateATK(-atk,true,e:GetHandler())
		end
	end
end