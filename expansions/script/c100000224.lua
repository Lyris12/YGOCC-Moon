--[[
Judgement of Verdanse
Giudizio di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Tribute up to 3 "Verdanse" Ritual Monsters you control with different names; randomly banish an equal number of face-down cards in your opponent's Extra Deck, face-down,
	then, if you banished 3 cards with this effect, inflict 3000 damage to your opponent.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[During your End Phase, if this card is in your GY, except during the turn it was sent there: You can banish this card and 1 "Verdanse" Ritual Monster from your GY;
	all monsters your opponent currently controls lose ATK equal to the banished monster's original ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetFunctions(
		aux.AND(aux.EndPhaseCond(0),aux.exccon),
		aux.DummyCost,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
end
--E1
function s.rfilter(c,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.rmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.fselect(g,tp)
	return g:GetClassCount(Card.GetCode)==#g and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	local ct=Duel.GetMatchingGroupCount(s.rmfilter,tp,0,LOCATION_EXTRA,nil,tp)
	local maxc=math.min(3,ct)
	if chk==0 then
		return e:IsCostChecked() and ct>0 and rg:CheckSubGroup(s.fselect,1,maxc,tp)
	end
	e:SetCategory(CATEGORY_REMOVE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:SelectSubGroup(tp,s.fselect,false,1,maxc,tp)
	aux.UseExtraReleaseCount(g,tp)
	local ct=Duel.Release(g,REASON_COST)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_EXTRA)
	if ct==3 then
		e:SetCategory(CATEGORY_REMOVE|CATEGORY_DAMAGE)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,3000)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct then return end
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_EXTRA,nil,tp)
	if #g<ct then return end
	local rg=g:RandomSelect(tp,ct)
	if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)==3 and Duel.GetGroupOperatedByThisEffect(e):GetCount()==3 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,3000,REASON_EFFECT)
	end
end

--E2
function s.cfilter(c,tp)
	local atk=c:GetTextAttack()
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and atk>0 and c:IsAbleToRemoveAsCost()
		and Duel.IsExists(false,Card.IsCanChangeAttack,tp,0,LOCATION_MZONE,1,c,-atk)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.cfilter,tp,LOCATION_GRAVE,0,1,c,tp)
	end
	local rg=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
	local atk=rg:GetFirst():GetTextAttack()
	Duel.SetTargetParam(atk)
	rg:AddCard(c)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetTargetParam()
	if not val then return end
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsCanChangeAttack,tp,0,LOCATION_MZONE,nil,-val)
	for tc in aux.Next(g) do
		tc:UpdateATK(-val,0,{c,true})
	end
end