--[[
CODED-EYES Cybernetic Dragon
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--link summon
	aux.AddLinkProcedure(c,s.matfilter,2,nil,s.lcheck)
	--atk down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1x:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e1x:SetCondition(s.condition)
	c:RegisterEffect(e1x)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantBattleTimings()
	e2:SetCondition(aux.ExceptOnDamageCalc)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return (c:IsLinkSetCard(ARCHE_CODE_JAKE) or c:IsLinkRace(RACE_MACHINE)) and not c:IsLinkType(TYPE_TOKEN)
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==#g
end

--E1
function s.cfilter(c,tp,se)
	return c:IsSummonPlayer(1-tp) and (se==nil or c:GetReasonEffect()~=se)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local se=e:GetLabelObject():GetLabelObject()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_LINK),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for linkc in aux.Next(g) do
		local fil=eg:Filter(s.cfilter,nil,tp,se)
		if #(fil&linkc:GetLinkedGroup())>0 or eg:IsExists(aux.zptfilter,1,nil,linkc) then
			return true
		end
	end
	return false
end
function s.addfilter(c)
	return c:IsFaceup() and c:IsAttack(c:GetBaseAttack())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_CARDS)
		if #g>1 then
			return false
		else
			return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		end
	end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.IsExistingMatchingCard(s.addfilter,tp,0,LOCATION_MZONE,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,0,1,nil)
		if g2 and #g2>0 then
			g1:Merge(g2)
		end
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g1,#g1,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	for tc in aux.Next(g) do
		tc:HalveATK(RESET_PHASE|PHASE_END,{c,true})
	end
end

--E2
function s.atkfilter(c,e)
	return c:IsFaceup() and (not e or c:IsCanBeEffectTarget(e)) and c:IsAttackAbove(2)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and lg:IsContains(chkc) and s.atkfilter(chkc) end
	if chk==0 then return lg:IsExists(s.atkfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=lg:FilterSelect(tp,s.atkfilter,1,1,nil,e)
	Duel.SetTargetCard(g)
	local og=lg:Clone()
	lg:Sub(g)
	lg:AddCard(c)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,-2,OPINFO_FLAG_HALVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,lg,#lg,0,0,math.floor(0.5 + g:GetFirst():GetAttack()/2))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToChain() then return end
	local g=c:GetLinkedGroup()
	local tc=Duel.GetFirstTarget()
	if not tc:IsFaceup() or not tc:IsRelateToChain() then return end
	g:RemoveCard(tc)
	g:AddCard(c)
	local e1,_,_,diff=tc:HalveATK(true,{c,true})
	if not tc:IsImmuneToEffect(e1) and diff<0 then
		for oc in aux.Next(g) do
			oc:UpdateATK(-diff,RESET_PHASE|PHASE_END,{c,true})
		end
	end
end