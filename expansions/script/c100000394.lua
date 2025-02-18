--[[
The Mirror of Delirium - Spectacle ZERO
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_VOIDICTATOR_RUNE_COURT_OF_THE_VOID)
	--[[Target 1 "Voidictator Rune - Court of the Void" you control that is not already affected by "Voidictator Rune - Inscription of Power"; it gains the following effects.
	● The first time each "Voidictator" monster you control would be destroyed by battle each turn, it is not destroyed, and if you took battle damage from that battle, it gains that much ATK after
	damage calculation, and keeps that ATK gain while this card is on the field.
	● The Special Summons of your "Voidictator Deity" and "Voidictator Demon" monsters cannot be negated.
	● Your opponent cannot Tribute "Voidictator" monsters you control.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is banished because of a "Voidictator" card you own: You can add 1 "Voidictator" card from your Deck or GY to your hand, except "Voidictator Rune - Inscription of Power".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetSearchFunctions(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_RUNE_COURT_OF_THE_VOID) and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and not tc:HasFlagEffect(id) then
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		local loc=tc:GetLocation()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetRange(loc)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_VOIDICTATOR))
		e1:SetValue(s.indct)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
		e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_SET_AVAILABLE)
		e2:SetRange(loc)
		e2:SetTarget(s.distg)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_RELEASE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetRange(loc)
		e3:SetTargetRange(0,1)
		e3:SetTarget(s.rellimit)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3)
		if loc==LOCATION_MZONE then
			aux.GainEffectType(tc,c)
		end
	end
end

function s.indct(e,re,r,rp)
	local c=e:GetHandler()
	if r&REASON_BATTLE==0 then return 0 end
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local tc=a:GetBattleTarget()
	if tc and tc:IsControler(1-tp) then a,tc=tc,a end
	local dam=Duel.GetBattleDamage(tp)
	if not tc or dam<=0 then return 1 end
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(dam)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(function (e)
		if not c:HasFlagEffect(id+100) then
			e1:Reset()
			e:Reset()
		end
	end)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)
	return 1
end

function s.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON)
end

function s.rellimit(e,c,tp,r)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetHandlerPlayer()) and c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR)
end

--E3
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and not c:IsCode(id)
end