--Paracyclisity Meteor Impact, Stagdominator
--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0X3308),2,99,s.lcheck)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.desop)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id+100)
	c:RegisterEffect(e1)
end
function s.lcheck(g,lg)
	return g:GetClassCount(Card.GetCode)==#g
end
function s.spfun(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desop(e,tp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_DECK,nil,TYPE_MONSTER)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if #g<5 or ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=g:Select(1-tp,5,5,nil)
	Duel.ConfirmCards(tp,tg)
	local sg1=tg:Filter(s.spfun,nil,e,1-tp)
	if #sg1>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg1=sg1:Select(1-tp,ft,ft,nil)
	end
	local ct1=Duel.SpecialSummon(sg1,0,1-tp,1-tp,false,false,POS_FACEUP)
	if ct1==0 then return end
	Duel.BreakEffect()
	Duel.ChangePosition(Duel.GetMatchingGroup(Card.IsCanBeTurnSet,tp,0,LOCATION_MZONE,nil),POS_FACEDOWN_DEFENSE)
	local g=Duel.GetOperatedGroup()
	if #g==0 then return end
	if Duel.Damage(1-tp,#g*500,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil),REASON_EFFECT)
		local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
			tc:RegisterEffect(e1)
		end
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.CheckLPCost(tp,2000)
	local b=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil)
	if chk==0 then return a or b end
	if a and b then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		e:SetLabel(opt)
		if opt==0 then Duel.PayLPCost(tp,2000) end
		if opt==1 then Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD) end
	elseif a then
		Duel.PayLPCost(tp,2000)
	elseif b then
		Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return true end
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	Duel.Damage(p,ct*500,REASON_EFFECT)
end
