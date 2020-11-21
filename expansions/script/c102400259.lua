--created & coded by Lyris, art from Cardfight!! Vanguard's "Blue Storm Marine General, Milos"
--アーマリン・サファイアー・セーラー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigRelayType(c)
	aux.AddRelayProc(c)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,s.mfilter,nil,nil,aux.NonTuner(Card.IsSetCard,0xa6c),1,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>4 or s[tp]>4 end)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:SetOperation(function() s[0]=Duel.GetActivityCount(0,ACTIVITY_ATTACK) s[1]=Duel.GetActivityCount(1,ACTIVITY_ATTACK) end)
		Duel.RegisterEffect(ge1,0)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0xa6c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ph=Duel.GetCurrentPhase()
	if chk==0 then return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE or Duel.GetTurnPlayer()~=tp or Duel.IsAbleToEnterBP())
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,99,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==0 then return end
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)-1
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetLabel(0)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xa6c))
	e1:SetCondition(function() return e1:GetLabel()<ct end)
	e1:SetValue(ct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EVENT_ATTACK_DISABLED)
	e3:SetOperation(function() local a=Duel.GetAttacker() if Duel.GetAttackTarget()~=nil and a:IsSetCard(0xa6c) and a:GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)<2 then e1:SetLabel(e1:GetLabel()+1) end if e1:GetLabel()>=ct then e2:Reset() e3:Reset() end end)
	Duel.RegisterEffect(e3,tp)
	e2:SetOperation(e3:GetOperation())
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
