--Daylilly Hydrangea
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddDaylillyFusionProcedures(c)
	--gain lp
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT(true)
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--spsummon
	aux.AddDaylillySpSummonEffect(c)
	--pop spell/trap
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetRelevantTimings()
	e3:SetCost(aux.DummyCost)
	e3:SetTarget(s.dtg)
	e3:SetOperation(s.dop)
	c:RegisterEffect(e3)
	--place in pzone
	Auxiliary.AddDaylillyPlacingEffect(c)
end
--E1
function s.cfilter1(c,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and c:GetTextAttack()>0 and (c:IsFaceup() or c:IsControler(tp))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.cfilter1,nil,tp)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		return #g1>0
	end
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
	local val=math.floor(sg:GetFirst():GetTextAttack()/2)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,val,REASON_EFFECT)
end

function s.cfilter3(c)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and Duel.IsExists(false,Card.IsSpellTrapOnField,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then
		if not e:IsCostChecked() or #g<=0 then return false end
		return Duel.CheckReleaseGroup(tp,s.cfilter3,1,nil)
	end
	local rg=Duel.SelectReleaseGroup(tp,s.cfilter3,1,1,nil)
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end