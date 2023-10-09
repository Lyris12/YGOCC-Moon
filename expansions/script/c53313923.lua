--Mysterious Supernova Dragon

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigPandemoniumType(c)
	aux.AddFusionProcFun2(c,s.ffilter,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),false)
	aux.AddContactFusionProcedureGlitchy(c,0,true,SUMMON_TYPE_FUSION,s.cffilter,LOCATION_MZONE|LOCATION_EXTRA,0,Duel.Remove,POS_FACEUP,REASON_COST)
	--You can target 1 monster you control, except during the Battle Phase; destroy all monsters on the field with a different Attribute than that monster, then destroy this card, and if you do, neither player takes damage until the end of the opponent's next turn. (HOPT1)
	local e0=Effect.CreateEffect(c)
	e0:Desc(1)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_SZONE)
	e0:HOPT()
	e0:SetRelevantTimings()
	e0:SetCondition(s.condition)
	e0:SetTarget(s.target)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
	aux.EnablePandemoniumAttribute(c,e0,true,TYPE_EFFECT|TYPE_FUSION)
	--Must be Fusion Summoned by banishing the above monsters you control or face-up in your Extra Deck. (You do not use "Polymerization").
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--This card gains the monster effects of cards in your Pandemonium Zone.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.copy)
	c:RegisterEffect(e3)
	--Gains 300 ATK for every other Pandemonium Monster on the field.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(s.sdcon)
	c:RegisterEffect(e4)
	--If this card in the Monster Zone is destroyed by battle or card effect: You can Set it into your Spell/Trap Zone.
	local e5=Effect.CreateEffect(c)
	e5:Desc(3)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(s.repcon)
	e5:SetTarget(s.reptg)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end
function s.ffilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionSetCard(0xcf6)
end
function s.cffilter(c)
	return c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end

function s.splimit(e,se,sp,st)
	return not se or aux.fuslimit(e,se,sp,st)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.PandActCheck(e) and not Duel.IsBattlePhase()
end
function s.filter(c,tp)
	local attr=c:GetAttribute()
	return c:IsFaceup() and attr>0 and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,attr)
end
function s.dfilter(c,at)
	local attr=c:GetAttribute()
	return c:IsFaceup() and attr>0 and attr~=at
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,g,g:GetFirst():GetAttribute())
	dg:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsFacedown() or tc:GetAttribute()==0 then return end
	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttribute())
	if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and e:GetHandler():IsDestructable(e) then
		local c=e:GetHandler()
		Duel.BreakEffect()
		if Duel.Destroy(c,REASON_EFFECT)==0 then return end
		local rct=Duel.GetNextPhaseCount(PHASE_END,1-tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,rct)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,rct)
		Duel.RegisterEffect(e2,tp)
		Duel.RegisterHint(tp,id,PHASE_END|RESET_OPPO_TURN,rct,id,2)
		Duel.RegisterHint(1-tp,id,PHASE_END|RESET_OPPO_TURN,rct,id,2)
	end
end

function s.copyfilter(c,fid)
	return c:IsInPandemoniumZone() and not c:HasFlagEffectLabel(id,fid)
end
function s.copy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local g=Duel.Group(s.copyfilter,tp,LOCATION_SZONE,0,nil,fid)
	for tc in aux.Next(g) do
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1,fid)
	end
end

function s.sdreq(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PANDEMONIUM)
end
function s.sdcon(e)
	return Duel.GetMatchingGroupCount(s.sdreq,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*300
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and not c:IsLocation(LOCATION_DECK)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.PandSSetFilter(nil,tp)(c) end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,c:GetControler(),0)
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.PandSSetFilter(nil,tp)(c) then
		aux.PandSSet(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	end
end
