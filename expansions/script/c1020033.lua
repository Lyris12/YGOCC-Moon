--[[
Galactic CODEMAN: Linked Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,nil,s.lcheck)
	--highlander
	c:SetUniqueOnField(1,0,id)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:OPT()
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetCost(aux.DummyCost)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
end
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end
function s.lcheck(g,lc)
	return g:IsExists(s.atkcheck,1,nil)
end

--E4
function s.val(e)
	local base=e:GetHandler():GetBaseAttack()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return 0 end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return math.floor(0.5 + math.abs(base-atk)/2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(s.cfilter,1,nil)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsAttackAbove(1000) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_UPDATE) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E2
function s.cfilter1(c,h,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost() and c:IsAttackAbove(1)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,Group.FromCards(c,h))
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chk==0 then
		return e:IsCostChecked() and lg:IsExists(s.cfilter1,1,nil,c,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=lg:FilterSelect(tp,s.cfilter1,1,1,nil,c,tp):GetFirst()
	local val=math.floor(0.5+tc:GetAttack()/2)
	Duel.SetTargetParam(val)
	Duel.SendtoGrave(tc,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,val)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local val=Duel.GetTargetParam()
	if tc:IsFaceup() and tc:IsRelateToChain() and val>0 then
		tc:UpdateATK(val,true,{e:GetHandler(),true})
	end
end