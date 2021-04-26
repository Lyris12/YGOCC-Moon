--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e) return Duel.GetCurrentPhase()==e:GetLabel() end)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetLabel(PHASE_BATTLE_START)
	e1:SetHintTiming(TIMING_BATTLE_START)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetLabel(PHASE_BATTLE_STEP)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetHintTiming(TIMING_ATTACK)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetLabel(PHASE_BATTLE)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e3:SetHintTiming(TIMING_BATTLE_END)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(function(e,tp) s[0]=0 s[1]=0 end)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local p=Duel.GetTurnPlayer()
	if chk==0 then return Duel.GetFieldGroupCount(p,0,LOCATION_MZONE)>=Duel.GetMatchingGroupCount(Card.IsAttackable,p,LOCATION_MZONE,0,1,nil) end
	local g1=Duel.GetMatchingGroup(Card.IsAttackable,p,LOCATION_MZONE,0,nil)
	local g2=Duel.GetFieldGroup(p,0,LOCATION_MZONE)
	local ct1=#g1
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,ct1*2,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g1=Duel.GetMatchingGroup(Card.IsAttackable,p,LOCATION_MZONE,0,nil)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	Duel.BreakEffect()
	local ct=Duel.Destroy(g1,REASON_EFFECT)
	if ct==0 then return end
	local g2=Duel.GetFieldGroup(p,0,LOCATION_ONFIELD)
	if #g2<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g2:Select(p,ct,ct,nil)
	Duel.HintSelection(sg)
	Duel.BreakEffect()
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.FromCards(Duel.GetBattleMonster(Duel.GetTurnPlayer()))
	if chk==0 then return #g==2 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g=Group.FromCards(Duel.GetBattleMonster(p))
	if #g<2 then return end
	local d=Duel.GetAttackTarget()
	local da=Duel.GetAttacker():GetBaseAttack()
	local dd=d:GetBaseAttack()
	Duel.Destroy(g,REASON_EFFECT)
	if g:IsExists(Card.IsOnField,1,nil) then return end
	if d:IsControler(p) then da,dd=dd,da end
	Duel.Damage(1-p,da,REASON_EFFECT,true)
	Duel.Damage(p,dd,REASON_EFFECT,true)
	Duel.RDComplete()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		local p=tc:GetPreviousControler()
		s[p]=s[p]+1
	end
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local tl=s[0]+s[1]
	local ct1=Duel.GetDecktopGroup(tp,tl):FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
	local ct2=Duel.GetDecktopGroup(1-tp,tl):FilterCount(Card.IsAbleToRemove,nil,1-tp,POS_FACEDOWN)
	if chk==0 then return (s[0]>0 or s[1]>0) and Duel.IsPlayerCanDraw(tp,s[tp]) and Duel.IsPlayerCanDraw(1-tp,s[1-tp]) and ct1==tl and ct2==tl end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetDecktopGroup(tp,Duel.Draw(tp,s[tp],REASON_EFFECT)+Duel.Draw(1-tp,s[1-tp],REASON_EFFECT))
	Duel.BreakEffect()
	Duel.DisableShuffleCheck()
	Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
end
