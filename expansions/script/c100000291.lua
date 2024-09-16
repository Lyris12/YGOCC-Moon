--[[
Dynastygian Ambusher - "Hound"
Unità di Imboscata Dinastigiana - "Segugio"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
local FLAG_MUST_ACTIVATE=id+200

function s.initial_effect(c)
	--[[If a "Dynastygian" monster you control attacks a Defense Position monster, inflict piercing battle damage to your opponent.]]
	c:InflictPiercingDamageField(LOCATION_MZONE,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DYNASTYGIAN))
	--[[During your opponent's turn, if your opponent Special Summons a monster(s) to their field while this card is in your hand or GY (Quick Effect):
	You can Special Summon this card, and if you do, banish 1 of those monsters. You must control a face-up "Dynastygian" monster to activate and resolve this effect.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.delayfilter,id,LOCATION_HAND|LOCATION_GRAVE,nil,LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetFunctions(
		s.spcon,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_CUSTOM+id+100)
	e2x:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2x)
	--[[You can target 1 "Dynastygian" Normal Trap in your GY; return this card to the hand, then Set that target to your opponent's field, and if you do,
	your opponent must activate that Set card during the next End Phase or else send it to the GY.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,p)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsControler(p)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(aux.AlreadyInRangeFilter(e,s.cfilter),nil,tp)
end
function s.recopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:FilterCount(aux.AlreadyInRangeFilter(e,s.cfilter),nil,tp)
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end
function s.recopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end

--E2
function s.delayfilter(c,e,tp,eg,ep,ev,re,r,rp,obj)
	local h=e:GetHandler()
	if obj and not aux.AlreadyInRangeCondition(nil,re,obj) then
		return false
	end
	return c:IsControler(1-tp) and c:IsSummonPlayer(1-tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsAbleToRemove,nil)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0
	end
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not s.spcon(e,tp,eg,ep,ev,re,r,rp) then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetTargetCards()
		if #g>0 then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			if #rg>0 then
				Duel.HintSelection(rg)
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

--E4
function s.setfilter(c,p)
	return c:IsNormalTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsSSetable(false,p)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc,1-tp) end
	if chk==0 then
		return c:IsAbleToHand() and Duel.IsExists(true,s.setfilter,tp,LOCATION_GRAVE,0,1,nil,1-tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,1-tp)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.BounceAndCheck(c) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and s.setfilter(tc,1-tp) then
			Duel.BreakEffect()
			if Duel.SSet(tp,tc,1-tp)>0 and aux.SetSuccessfullyFilter(tc) and tc:IsControler(1-tp) then
				local rct=Duel.GetNextPhaseCount(PHASE_END)
				local tct=rct==1 and -1 or Duel.GetTurnCount()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetLabel(tct)
				e1:SetCondition(s.fastactcon)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				--
				local eid=e:GetFieldID()
				tc:RegisterFlagEffect(FLAG_MUST_ACTIVATE,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,rct,eid,aux.Stringid(id,2))
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(id,3)
				e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE|PHASE_END)
				e2:OPT()
				e2:SetLabel(eid,tct)
				e2:SetLabelObject(tc)
				e2:SetCondition(s.actcon)
				e2:SetOperation(s.actop)
				e2:SetReset(RESET_PHASE|PHASE_END,rct)
				Duel.RegisterEffect(e2,1-tp)
			end
		end
	end
end
function s.fastactcon(e)
	return Duel.IsEndPhase() and Duel.GetTurnCount()~=e:GetLabel()
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local eid,tct=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(FLAG_MUST_ACTIVATE,eid) then
		e:Reset()
		return false
	end
	return Duel.IsEndPhase() and Duel.GetTurnCount()~=tct
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local effect=tc:GetActivateEffect()
	if effect and effect:IsActivatable(tp) then
		Duel.Activate(effect)
	else
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE)
	end
	e:Reset()
end