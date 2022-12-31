--Ninja Paralizzante Puntodifuoco
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	--topdeck management
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.topcon)
	e1:SetTarget(cid.toptg)
	e1:SetOperation(cid.topop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.discon)
	e2:SetTarget(cid.distg)
	e2:SetOperation(cid.disop)
	c:RegisterEffect(e2)
end
--destroy
function cid.topcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cid.toptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(1-tp,5)
	local deck=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if chk==0 then return deck>=5 and (g:IsExists(Card.IsAbleToRemove,5,nil) or Duel.IsPlayerCanDiscardDeck(1-tp,5)) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)
end
function cid.topop(e,tp,eg,ep,ev,re,r,rp)
	local deck=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if deck<5 then return end
	local g=Duel.GetDecktopGroup(1-tp,5)
	local opt1,opt2=g:IsExists(Card.IsAbleToRemove,5,nil),Duel.IsPlayerCanDiscardDeck(1-tp,5)
	local op=0
	if opt1 and opt2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif opt1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif opt2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else
		return
	end
	if op==0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	else
		Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
	end
end
--disable
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	local tgp=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev) and tgp~=tp
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	Duel.NegateEffect(ev)
end