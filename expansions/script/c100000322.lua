--[[
Number 204: Invernal of the Thousand Blades
Numero 204: Invernale delle Mille Lame
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 6 DARK monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),6,2,nil,nil,99)
	--Cannot be targeted or destroyed by card effects.
	c:CannotBeTargetedByEffects()
	c:CannotBeDestroyedByEffects()
	--[[If this card is Xyz Summoned: You can destroy cards your opponent controls, up to the number of materials attached to this card.
	Cards destroyed by this effect cannot activate their own effects during that same turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[During damage calculation, if this card battles an opponent's monster (Quick Effect): You can detach any number of materials from this card;
	this card gains 1000 ATK for each detached material, during that damage calculation only.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.atkcon,aux.DummyCost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end
aux.xyz_number[id]=204

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then
		return c:GetOverlayCount()>0 and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local ct=c:GetOverlayCount()
		if ct==0 then return end
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if Duel.Destroy(g,REASON_EFFECT)>0 then
				local og=Duel.GetGroupOperatedByThisEffect(e)
				for tc in aux.Next(og) do
					local e1=Effect.CreateEffect(c)
					e1:SetDescription(STRING_CANNOT_TRIGGER)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
					e1:SetCode(EFFECT_CANNOT_TRIGGER)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
					tc:RegisterEffect(e1)
				end
			end
		end
	end
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return false end
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	local ct=c:RemoveOverlayCard(tp,1,999,REASON_COST)
	local val=ct*1000
	Duel.SetTargetParam(val)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,val)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local val=Duel.GetTargetParam()
		c:UpdateATK(val,RESET_PHASE|PHASE_DAMAGE_CAL,c)
	end
end