--[[
Azura, Godspark of the Dark Waters
Azura, Divinascintilla delle Acque Oscure
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,3,3,s.altfilter,aux.Stringid(id,0),s.alterop)
	--You can only Special Summon "Azura, Godspark of the Dark Waters" once per turn.
	c:SetSPSummonOnce(id)
	--While face-up on the field, this card is also DARK-Attribute.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can target 1 "Godspark" card you control; for as long as you control this face-up card, that card cannot be targeted or destroyed
	by your opponent's card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.tgtg,
		s.tgop
	)
	c:RegisterEffect(e1)
	--[[When your opponent activates a card or effect, if "Gorgeous Gift of Heaven - The Godspark" is in your GY (Quick Effect):
	You can detach 1 material from this card, then target 1 face-up card your opponent controls;  negate its effects until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		s.discon,
		aux.DetachSelfCost(),
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsSetCard(ARCHE_GODSPARK)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetCode)==#g
end
function s.altfilter(c,xyzc)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsSetCard(ARCHE_GODSPARK)
end
function s.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(ARCHE_GODSPARK)
end
function s.dcfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_GODSPARK) and c:IsDiscardable()
end
function s.alterop(e,tp,chk,c)
	if chk==0 then
		return Duel.IsExists(false,s.lkfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(false,s.dcfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST|REASON_DISCARD)
end

--E1
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_GODSPARK)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCondition(s.indcon)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCondition(s.indcon)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.indcon(e)
	local c=e:GetOwner()
	local res=c:IsOnField() and c:IsFaceup() and c:IsHasCardTarget(e:GetHandler()) 
	if not res then
		e:Reset()
	end
	return res
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_GORGEOUS_GIFT_OF_HEAVEN_THE_GODSPARK),tp,LOCATION_GRAVE,0,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.Negate(tc,e,RESET_PHASE|PHASE_END)
	end
end