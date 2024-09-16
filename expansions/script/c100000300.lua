--[[
Dynastygian Sabotage - Weapons Jam
Sabotaggio Dinastigiano - Inceppamento Armi
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()

local PFLAG_ALREADY_IN_OPPO_BP 		 	= id
local PFLAG_ALREADY_DECLARED_ATTACK 	= id+100
local PFLAG_ALREADY_REGISTERED_EFFECT 	= id+200

local FLAG_CHOSEN_AS_ATTACKER			= id
local FLAG_NOT_CHOSEN_AS_ATTACKER		= id+100

local EVENT_MUST_CHOOSE_ATTACKER_AGAIN	= EVENT_CUSTOM+id

function s.initial_effect(c)
	--[[Activate 1 of the following effects, depending on who the owner of this card is.
	● You: During your opponent's next Battle Phase, they can only attack with 1 monster, and only the monster with the lowest ATK among monsters they control (your choice, if tied).
	● Your opponent: Until the end of the next turn, whenever your opponent takes battle or effect damage, you take damage equal to the damage they took, also,
	if your opponent would take 2000 or more battle or effect damage from a card or effect you own, they take 1000 damage, instead (but you still take damage equal to the original amount they would have taken).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this Set card in your opponent's Spell & Trap Zone is sent to the GY: You can target 1 monster in your opponent's GY or banishment with 1000 or more ATK;
	until the end of the next turn, the original ATK/DEF of all monsters your opponent controls will become equal to half of that target's original ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,5)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local p=c:GetOwner()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if chk==0 then return p~=tp or not Duel.PlayerHasFlagEffect(1-tp,PFLAG_ALREADY_REGISTERED_EFFECT) end
	if p==tp then
		Duel.SetTargetParam(1)
	elseif p==1-tp then
		Duel.SetTargetParam(2)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local param=Duel.GetTargetParam()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if param==1 then
		local rct=Duel.GetNextBattlePhaseCount(1-tp)
		Duel.RegisterFlagEffect(1-tp,PFLAG_ALREADY_REGISTERED_EFFECT,RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,0,rct)
		if rct==2 then
			Duel.RegisterFlagEffect(1-tp,PFLAG_ALREADY_IN_OPPO_BP,RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,0,1)
		end
		--Prevent monsters that do not have the lowest attack from attacking. Also, if a monster already declared an attack, prevents all other monsters from attacking during that BP
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(id,1)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
		e7:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e7:SetTargetRange(LOCATION_MZONE,0)
		e7:SetLabel(rct)
		e7:SetCondition(s.checkcon)
		e7:SetOwnerPlayer(1-tp)
		e7:SetTarget(s.atktg)
		e7:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,rct)
		Duel.RegisterEffect(e7,1-tp)
		--Raises flag for when an attack is declared
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_ATTACK_ANNOUNCE)
		e8:SetLabel(rct)
		e8:SetCondition(s.checkcon)
		e8:SetOperation(s.checkop)
		e8:SetLabelObject(e7)
		e8:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,rct)
		Duel.RegisterEffect(e8,1-tp)
		--At the start of BP, choose which monster can attack (if multiple choices are available), and register auxiliary effects to enable rechoice at a later time if gamestate changes
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
		e9:OPT()
		e9:SetLabel(rct)
		e9:SetCondition(s.checkcon2)
		e9:SetOperation(s.decide_attacker)
		e9:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,rct)
		Duel.RegisterEffect(e9,tp)
		--Rechoose attacker if gamestate changed
		local e10=Effect.CreateEffect(c)
		e10:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_MUST_CHOOSE_ATTACKER_AGAIN)
		e10:SetCondition(s.preventChoiceIfAlreadyAttacked)
		e10:SetOperation(s.decide_attacker)
		e10:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,rct)
		Duel.RegisterEffect(e10,tp)
	elseif param==2 then
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(id,2)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e7:SetCode(EFFECT_GLITCHY_ALSO_EFFECT_DAMAGE)
		e7:SetTargetRange(1,0)
		e7:SetOwnerPlayer(1-tp)
		e7:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e7,1-tp)
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
		e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetOwnerPlayer(1-tp)
		e8:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e8,1-tp)
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_FIELD)
		e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e9:SetCode(EFFECT_CHANGE_DAMAGE)
		e9:SetTargetRange(1,0)
		e9:SetOwnerPlayer(1-tp)
		e9:SetValue(s.damval)
		e9:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e9,1-tp)
		local e10=Effect.CreateEffect(c)
		e10:SetType(EFFECT_TYPE_FIELD)
		e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e10:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e10:SetTargetRange(1,0)
		e10:SetOwnerPlayer(1-tp)
		e10:SetCondition(s.bdamval)
		e10:SetValue(1000)
		e10:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e10,1-tp)
	end
end
function s.atktg(e,c)
	local tp=e:GetOwnerPlayer()
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local gmin=g:GetMinGroup(Card.GetAttack)
	local label=Duel.PlayerHasFlagEffect(tp,PFLAG_ALREADY_DECLARED_ATTACK) and Duel.GetFlagEffectLabel(tp,PFLAG_ALREADY_DECLARED_ATTACK) or -1
	if label~=-1 and c:GetFieldID()~=e:GetLabel() then
		return true
	end
	return not gmin:IsContains(c) or c:HasFlagEffect(FLAG_NOT_CHOSEN_AS_ATTACKER)
end
function s.checkcon(e,tp)
	if not tp then tp=e:GetOwnerPlayer() end
	return Duel.GetTurnPlayer()==tp and (e:GetLabel()==1 or not Duel.PlayerHasFlagEffect(tp,PFLAG_ALREADY_IN_OPPO_BP))
end
function s.checkcon2(e,tp)
	return s.checkcon(e,1-tp)
end
function s.validAttackerFilter(c)
	return c:IsFaceup() and c:IsAttackable()
end
function s.decide_attacker(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	for tc in aux.Next(g) do
		tc:ResetFlagEffect(FLAG_CHOSEN_AS_ATTACKER)
		tc:RegisterFlagEffect(FLAG_NOT_CHOSEN_AS_ATTACKER,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	end
	local gmin=g:Filter(s.validAttackerFilter,nil):GetMinGroup(Card.GetAttack)
	local tc
	if #gmin>1 then
		Duel.HintMessage(tp,aux.Stringid(id,3))
		local tg=gmin:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		tc=tg:GetFirst()
		tc:ResetFlagEffect(FLAG_NOT_CHOSEN_AS_ATTACKER)
	else
		tc=gmin:GetFirst()
	end
	tc:RegisterFlagEffect(FLAG_CHOSEN_AS_ATTACKER,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	tc:ResetFlagEffect(FLAG_NOT_CHOSEN_AS_ATTACKER)
	local c=e:GetOwner()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetLabel(0)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE,1)
	--Toggles optional rechoice at the end of a Chain (due to secondary gamestate change that did not involve the chosen attacker)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.raiseOptionalRechoice)
	e2:SetReset(RESET_PHASE|PHASE_BATTLE,1)
	Duel.RegisterEffect(e2,tp)
	e1:SetOperation(s.chooseAgain(e2))
	Duel.RegisterEffect(e1,tp)
end
function s.chooseAgain(e2)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=e:GetLabelObject()
				local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
				local gmin=g:Filter(s.validAttackerFilter,nil):GetMinGroup(Card.GetAttack)
				local optional=g:IsExists(aux.NOT(Card.HasFlagEffect),1,tc,FLAG_NOT_CHOSEN_AS_ATTACKER) or (#gmin>1 and e:GetLabel()==1)
				e:SetLabel(0)
				if not tc or not gmin:IsContains(tc) or not tc:HasFlagEffect(FLAG_CHOSEN_AS_ATTACKER) or (optional and Duel.SelectYesNo(tp,aux.Stringid(id,4))) then
					Duel.RaiseEvent(Group.CreateGroup(),EVENT_MUST_CHOOSE_ATTACKER_AGAIN,e,0,tp,tp,0)
					e2:Reset()
					e:Reset()
				end
			end
end
function s.preventChoiceIfAlreadyAttacked(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.PlayerHasFlagEffect(tp,PFLAG_ALREADY_DECLARED_ATTACK)
end
function s.raiseOptionalRechoice(e)
	e:GetLabelObject():SetLabel(1)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.PlayerHasFlagEffect(tp,PFLAG_ALREADY_DECLARED_ATTACK) then return end
	local fid=eg:GetFirst():GetFieldID()
	Duel.RegisterFlagEffect(tp,PFLAG_ALREADY_DECLARED_ATTACK,RESET_PHASE|PHASE_BATTLE,0,1,fid)
end
function s.damval(e,re,val,r,rp,rc)
	if val>=2000 and r&REASON_EFFECT>0 and re and re:GetHandler():GetOwner()==1-e:GetOwnerPlayer() then
		return 1000
	else
		return val
	end
end
function s.bdamval(e)
	local tp=e:GetOwnerPlayer()
	return Duel.GetBattleMonster(1-tp)~=nil and Duel.GetBattleDamage(1-tp)>=2000
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5 and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsAttackAbove(1000)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(1-tp) and s.atkfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.atkfilter,tp,0,LOCATION_GB,1,nil)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.atkfilter,tp,0,LOCATION_GB,1,1,nil)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and s.atkfilter(tc) then
		local atk=math.ceil(tc:GetBaseAttack()/2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		Duel.RegisterEffect(e2,tp)
	end
end