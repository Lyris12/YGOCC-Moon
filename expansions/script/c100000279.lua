--[[
Sceluspecter Recurring Phantom
Scelleraspettro Spirito Ricorrente
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),2,2)
	--[[If this card is Link Summoned: You can send 2 "Sceluspecter" monsters from your hand and/or Deck to the GY; add 1 "Sceluspecter" card from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		s.thcost,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	--[[This card can be treated as a Level 7 monster for the Xyz Summon of "Number 201: Sceluspecter Phantom Magician"]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.xyzlv)
	c:RegisterEffect(e2)
	--[[While this card is attached to a DARK "Number" Xyz Monster as material, negate the effects of all Special Summoned monsters your opponent controls.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetCondition(s.discon(0))
	e3:SetAbsoluteRange(0,0,LOCATION_MZONE)
	e3:SetTarget(s.disable)
	Duel.RegisterEffect(e3,0)
	local e4=e3:Clone()
	e4:SetCondition(s.discon(1))
	e4:SetAbsoluteRange(1,0,LOCATION_MZONE)
	e4:SetTarget(s.disable)
	Duel.RegisterEffect(e4,1)
	--Each time a DARK monster(s) is banished from the GY, immediately draw 1 card.
	aux.RegisterMaxxCEffect(c,id,nil,LOCATION_MZONE,EVENT_REMOVE,s.drawcon,s.chainOUT,s.chainIN,nil,nil,nil,nil,aux.AddThisCardInMZoneAlreadyCheck(c))
end

--E1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGraveAsCost()
end
function s.gcheck(g,e,tp)
	if #g<2 then return true end
	return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,g)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_DECK|LOCATION_HAND,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(tg,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2
function s.xyzlv(e,c,xyzc)
	if xyzc:IsCode(CARD_NUMBER_201) then
		return 7
	else
		return 0
	end
end

--E3
function s.discon(p)
	return	function(e)
				local c=e:GetOwner()
				if not c:IsLocation(LOCATION_OVERLAY) or c:IsDisabled() then return false end
				local xyzc=c:GetOverlayTarget()
				return xyzc:IsControler(p) and xyzc:IsFaceup() and xyzc:IsType(TYPE_XYZ) and xyzc:IsSetCard(ARCHE_NUMBER) and xyzc:IsAttribute(ATTRIBUTE_DARK)
			end
end
function s.disable(e,c)
	return c:IsSpecialSummoned() and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)
end

--E5
function s.cfilter2(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter2),1,nil)
end
function s.chainOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.chainIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Draw(tp,n,REASON_EFFECT)
end