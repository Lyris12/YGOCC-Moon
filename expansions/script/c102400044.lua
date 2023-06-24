--created & coded by Lyris, art from "The Wyvern"
--ザ☆機光襲雷
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,4)
	local e1=c:DriveEffect(0,nil,nil,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_DESTROYED,nil,nil,nil,s.dcop)
	local e2=c:DriveEffect(1,0,CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,nil,nil,s.dstg,s.dsop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil)
	if c and c:IsEngaged() and c:IsEnergyAbove(1) then
		c:UpdateEnergy(-#g,tp,REASON_EFFECT)
	end
end
function s.dfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsSetCard(0x7c4)
end
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x7c4) and (not c:IsForbidden() and c:IsType(TYPE_PENDULUM)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_ONFIELD,0,1,1,nil),1,0,0)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	local op=aux.SelectFromOptions(tp,{not sc:IsForbidden() and sc:IsType(TYPE_PENDULUM)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1),1160},
		{Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false),1152})
	local chk=false
	if op==1 then chk=Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else chk=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 end
	local tc=Duel.GetFirstTarget()
	if chk and tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetAttackTarget()==e:GetHandler()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(0xff,0)
	e1:SetTarget(s.ptarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(aux.indoval)
	Duel.RegisterEffect(e1,tp)
end
function s.ptarget(e,c)
	return c:IsSetCard(0x7c4) and c:GetOriginalType()&TYPE_MONSTER==0
end
