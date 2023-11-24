--created by Seth, coded by Lyris
--Great London Brother Mark
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Great London")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:HOPT()
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.AnnounceType(tp))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.ConfirmDecktop(1-tp,1)
	if not tc:IsType(1<<e:GetLabel()) then return end
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,1,1,nil)
	Duel.HintSelection(sg)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard({"Great London", "Clue"})
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttackTarget()
	e:SetLabelObject(bc)
	return Duel.GetAttacker()==c and bc~=nil
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,3,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
function s.afilter(c,tp)
	local e=c:GetActivateEffect()
	return c:IsSetCard({"Great London", "Clue"}) and e and e:IsActivatable(tp,true,true)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if not bc:IsRelateToBattle() or Duel.Destroy(bc,REASON_EFFECT)<1 then return end
	local g=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_DECK,0,nil,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.BreakEffect()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end
