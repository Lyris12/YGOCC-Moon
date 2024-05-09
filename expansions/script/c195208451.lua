--created by Seth, coded by Lyris
--Great London Evil Professor Jack
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString"Great London"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetDescription(1100)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetDescription(1190)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:HOPT()
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetCondition(s.dbcon)
	e3:SetTarget(s.dbtg)
	e3:SetOperation(s.dbop)
	c:RegisterEffect(e3)
end
function s.dbcon(e,tp)
	return Duel.GetAttacker()==e:GetHandler() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,3,nil)
end
function s.dbtg(e,tp,_,_,_,_,_,_,chk)
	local bc=Duel.GetAttackTarget()
	if chk==0 then return bc~=nil and bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.dbop(e,tp)
	local bc=Duel.GetAttackTarget()
	if not (bc and bc:IsRelateToBattle()) or Duel.Destroy(bc,REASON_EFFECT)<1 then return end
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
function s.descon()
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard{"Great London", "Clue"}
end
function s.destg(e,tp,_,_,_,_,_,_,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) and #g>1 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.desop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	g:Merge(Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,sg))
	if #g<2 then return end
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.sfilter(c)
	return c:IsSetCard{"Great London", "Clue"} and c:IsAbleToHand()
end
function s.thtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
function s.thop(e,tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return end
	Duel.ConfirmDecktop(tp,1)
	if not Duel.GetDecktopGroup(tp,1):GetFirst():IsType(1<<Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_RULE)
	Duel.ConfirmCards(1-tp,g)
end
