--Terradication Fullbladetyranno
--created by Swag, coded by Lyris

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	aux.AddFusionProcFunRep2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_PANDEMONIUM),2,99,true)
	aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_MZONE,0,Duel.Release,REASON_COST|REASON_MATERIAL)
	--You cannot Pandemonium Summon monsters, except Dinosaur monsters.
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_FIELD)
	p0:SetRange(LOCATION_SZONE)
	p0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE)
	p0:SetTargetRange(1,0)
	p0:SetCondition(s.pscon)
	p0:SetTarget(s.pslimit)
	c:RegisterEffect(p0)
	--Once per turn: You can send 1 Pandemonium Monster from your hand, or face-up Extra Deck, to the GY, then target 1 card your opponent controls; place it on the top of the Deck.
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_TODECK)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCountLimit(1)
	p1:SetRelevantTimings()
	p1:SetCost(s.cost)
	p1:SetTarget(s.target)
	p1:SetOperation(s.activate)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_EFFECT|TYPE_FUSION)
	--[[If this card is Fusion Summoned: You can destroy monsters your opponent controls, up to the number of "Terradication" monsters used as material to Summon this card,
	then inflict 500 damage to your opponent for each monster destroyed by this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--If this card attacks a Defense Position monster, inflict piercing battle damage.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--Once per turn: You can send 1 Pandemonium Monster from your hand, or face-up Extra Deck, to the GY, then target 1 Spell/Trap your opponent controls; destroy it.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--If this card leaves the field because of a card effect: You can Set it in your Spell & Trap Zone.
	local e4=Effect.CreateEffect(c)
	e4:Desc(3)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.pscon(e)
	return aux.PandActCheck(e) and not e:GetHandler():IsForbidden()
end
function s.pslimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DINOSAUR) and sumtype&SUMMON_TYPE_PANDEMONIUM==SUMMON_TYPE_PANDEMONIUM
end

function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PANDEMONIUM)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA|LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA|LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.activate(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterial():FilterCount(Card.IsSetCard,nil,0x9b5)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=c:GetMaterial():FilterCount(Card.IsSetCard,nil,0x9b5)
	if ct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.HintSelection(g)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsSpellTrapOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and not c:IsLocation(LOCATION_DECK)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.PandSSetFilter(nil,tp)(c) end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,c:GetControler(),0)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.PandSSetFilter(nil,tp)(c) then
		aux.PandSSet(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	end
end