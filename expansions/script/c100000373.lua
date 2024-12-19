--[[
Vacuous Nightmare - ZERO HORIZON
Incubo Vacuo - ORIZZONTE ZERO
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	c:EnableReviveLimit()
	--[[Must be Special Summoned (from your Extra Deck) by sending "Vacuous Shadow" and "Vacuous Archfiend" from your field to the GY during the same turn you activated and resolved the effect of
	"Perfect ZERO".]]
	c:MustBeSSedByOwnProcedure()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(id,2)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.sprcon)
	e0:SetTarget(s.sprtg)
	e0:SetOperation(s.sprop)
	c:RegisterEffect(e0)
	--[[Unaffected by other cards and effects, except the effects of "Power Vacuum Blade", "Power Vacuum Zone", and Traps that mention "Power Vacuum Zone".]]
	c:Unaffected(s.imval)
	--[[If this card is Special Summoned: Banish as many cards from both player's Decks and GYs as possible, face-down, and if you do, take 1 "Power Vacuum Blade" from your hand or banishment and
	equip it to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e1)
	--[[While this card is face-up on the field, both players skip their Draw Phase and Main Phase 2.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCode(EFFECT_SKIP_DP)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_SKIP_M2)
	c:RegisterEffect(e2a)
	--[[If this card battles an opponent's monster, your opponent cannot activate cards or effects until the end of the Damage Step, also at the end of the Damage Step, halve your opponent's LP.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actlimcon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.damrmcon)
	e4:SetOperation(s.damrmop)
	c:RegisterEffect(e4)
end
function s.imval(e,te)
	local tec=te:GetOwner()
	return e:GetOwner()~=tec and not tec:IsCode(CARD_POWER_VACUUM_BLADE,CARD_POWER_VACUUM_ZONE)
		and not (te:IsActiveType(TYPE_TRAP) and tec:Mentions(CARD_POWER_VACUUM_ZONE))
end

--E0
function s.sprfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
function s.fselect(g,tp,sc)
	return aux.gfcheck(g,Card.IsCode,CARD_VACUOUS_SHADOW,CARD_VACUOUS_ARCHFIEND) and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if not Duel.PlayerHasFlagEffect(tp,100000373) then return false end
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_ONFIELD,0,nil)
	return g:CheckSubGroup(s.fselect,2,2,tp,c)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end

--E1
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local g=Duel.Group(Card.IsAbleToRemove,tp,LOCATION_DECK|LOCATION_GRAVE,LOCATION_DECK|LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.eqfilter(c,tp,ec)
	return c:IsFaceupEx() and c:IsCode(CARD_POWER_VACUUM_BLADE) and s.eqcheck(c,ec,tp)
end
function s.eqcheck(c,ec,tp)
	if c:IsType(TYPE_EQUIP) then
		return c:IsAppropriateEquipSpell(ec,tp)
	else
		return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(aux.Necro(Card.IsAbleToRemove),tp,LOCATION_DECK|LOCATION_GRAVE,LOCATION_DECK|LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 and c:IsRelateToChain() and c:IsFaceup() then
		local ec=Duel.Select(HINTMSG_EQUIP,false,tp,s.eqfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,tp,c):GetFirst()
		if ec then
			if ec:IsType(TYPE_EQUIP) then
				Duel.Equip(tp,ec,c)
			else
				Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,c)
			end
		end
	end
end

--E3
function s.actlimcon(e)
	local c=e:GetHandler()
	return (Duel.GetAttacker()==c and c:GetBattleTarget()) or Duel.GetAttackTarget()==c
end

--E4
function s.damrmcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if not bc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsControler(1-tp)
	else
		return bc:IsPreviousControler(1-tp)
	end
end
function s.damrmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.HalveLP(1-tp)
end