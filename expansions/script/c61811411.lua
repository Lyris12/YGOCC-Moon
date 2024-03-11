--[[
Dread Bastille's Intermezzo
Intermezzo della Bastiglia dell'Angoscia
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When your opponent activates a Spell/Trap Card, or monster effect, while you control a "Dread Bastille" Xyz Monster:
	You can send 1 "Dread Bastille" monster from your hand or field to the GY, and if you do, negate the activation, and if you do that, you can attach that card to a "Dread Bastille" Xyz Monster you control as material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[During your opponent's Battle Phase: You can banish this card from your GY, then target 1 monster you control and 1 monster your opponent controls;
	that opponent's monster must attack your targeted monster this turn, if able.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantBattleTimings()
	e2:HOPT()
	e2:SetFunctions(aux.BattlePhaseCond(1),aux.bfgcost,s.tg,s.op)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_DREAD_BASTILLE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToGrave()
end
function s.infofilter(c)
	return not c:IsPublic() or not (c:IsMonster() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToGrave())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if not Duel.IsExistingMatchingCard(s.infofilter,tp,LOCATION_HAND,0,1,nil) then
		local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_HAND|LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	end
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_DREAD_BASTILLE) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsInGY() and Duel.NegateActivation(ev) then
		local rc=re:GetHandler()
		if rc and rc:IsRelateToChain(ev) then
			local g=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
			if #g>0 and rc:IsCanOverlay(tp) and Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
				Duel.HintMessage(tp,HINTMSG_ATTACHTO)
				local xyz=g:Select(tp,1,1,nil)
				if #xyz>0 and not rc:IsImmuneToEffect(e) then
					rc:CancelToGrave()
					Duel.HintSelection(xyz)
					Duel.Attach(rc,xyz:GetFirst())
				end
			end
		end
	end
end

--E2
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExists(true,nil,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(true,nil,tp,0,LOCATION_MZONE,1,nil)
	end
	local g1=Duel.Select(HINTMSG_TARGET,true,tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	local g2=Duel.Select(HINTMSG_TARGET,true,tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	g2:GetFirst():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g~=2 then return end
	local tc1,tc2=g:GetFirst(),g:GetNext()
	if not tc2:HasFlagEffect(id) then
		tc1,tc2=tc2,tc1
	end
	if not tc1:IsControler(tp) or not tc2:IsControler(1-tp) then return end
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetLabel(tc1:GetRealFieldID())
	e2:SetLabelObject(tc1)
	e2:SetCondition(s.macon)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc2:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	tc2:RegisterEffect(e3)
end
function s.macon(e)
	local c=e:GetLabelObject()
	if not (c and c:GetRealFieldID()==e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.atklimit(e,c)
	local tc=e:GetLabelObject()
	return c==tc and tc:GetRealFieldID()==e:GetLabel()
end