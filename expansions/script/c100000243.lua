--[[
Neo Clockwork Spire
Neo Spira a Orologeria
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:Activation(true)
	--[[Once per turn: You can discard 1 "Automatyrant" Normal or Quick-Play Spell that meets its activation conditions; this effect becomes that Spell's activation effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:OPT()
	e1:SetFunctions(nil,aux.DummyCost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[Equip Cards you control that are equipped to a monster you control cannot be targeted by your opponent's card effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--[[While you control 5 face-up cards in your Spell & Trap Zone, all "Automatyrant" monsters you control gain 800 ATK/DEF.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_AUTOMATYRANT))
	e3:SetValue(800)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
end

--E1
function s.filter(c)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and (c:IsNormalSpell() or c:IsSpell(TYPE_QUICKPLAY)) and c:IsDiscardable() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return e:IsCostChecked() and Duel.IsExists(false,s.filter,tp,LOCATION_HAND,0,1,nil) end
	e:SetProperty(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.Select(HINTMSG_DISCARD,false,tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SendtoGrave(tc,REASON_COST|REASON_DISCARD)	
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		local tg=te:GetTarget()
		e:SetProperty(te:GetProperty())
		if tg then tg(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		e:SetCategory(0)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(te,tp,eg,ep,ev,re,r,rp)
	end
end

--E2
function s.tgtg(e,c)
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(e:GetHandlerPlayer())
end

--E3
function s.atkcon(e)
	return Duel.IsExists(false,aux.AND(Card.IsFaceup,Card.IsInBackrow),e:GetHandlerPlayer(),LOCATION_SZONE,0,5,nil)
end