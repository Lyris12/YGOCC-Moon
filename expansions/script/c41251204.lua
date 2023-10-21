--Daylilly Rose
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddDaylillyFusionProcedures(c)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DAMAGE)
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
	--atk
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e3:SetCondition(aux.ExceptOnDamageCalc)
	e3:SetCost(aux.TributeCost(s.cfilter3))
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
	local dam=math.floor(sg:GetFirst():GetTextAttack()/2)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,dam,REASON_EFFECT)
end

function s.cfilter3(c,_,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:HasAttack()
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),LOCATION_MZONE,400)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:HasAttack() then
		c:UpdateATK(400,true,c)
	end
end