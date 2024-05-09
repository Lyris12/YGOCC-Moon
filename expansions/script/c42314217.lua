--created by Jake, coded by Lyris
--Dawn Blader - Paladin of Experience
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),aux.NonTuner(nil),1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCondition(s.drcon)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetCondition(s.dcon)
	e2:SetCost(s.dcost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(s.decon)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.dscon)
	c:RegisterEffect(e4)
end
function s.drcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.rfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x613)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.rfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>1 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	e:SetLabel(Duel.DiscardHand(tp,Card.IsDiscardable,ct,ct,REASON_COST+REASON_DISCARD)-1)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.drop(e,tp)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.dcon(e,tp,eg)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.decon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:FilterCount(s.filter,nil,tp)==1
end
function s.dfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_WARRIOR>0 and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()==1-tp)
end
function s.dscon(e,tp,eg)
	return eg:FilterCount(s.dfilter,nil,tp)==1
end
function s.cfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetParam(1)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.dop(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)<1 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	if not (tc:IsRace(RACE_WARRIOR) and Duel.SelectEffectYesNo(tp,e:GetHandler(),1191)) then return end
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
end
