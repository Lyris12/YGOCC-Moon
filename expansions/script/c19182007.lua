--Aircaster Savant
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(2)
	e0:SetCategory(CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetFunctions(s.atkcon,nil,s.atktg,s.atkop)
	e0:SetReset(RESET_PHASE|PHASE_END)
	local ex=aux.AddAircasterExcavateEffect(c,6,EFFECT_TYPE_QUICK_O,0,id,e0,CATEGORY_ATKCHANGE)
	e0:SetLabelObject(ex)
	aux.AddAircasterEquipEffect(c,1)
	--The first time a monster equipped with this card would be destroyed by battle each turn, it is not destroyed.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetCondition(s.econ)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	if chk==0 then return true end
	local eid=e:GetLabel()
	local ct=eg:FilterCount(s.cfilter,nil,eid,e:GetLabelObject())
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,g:GetControlers(),LOCATION_MZONE,{0})
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	for tc in aux.Next(g) do
		tc:ChangeATK(0,true,e:GetHandler())
	end
end

function s.econ(e)
	return e:GetHandler():IsSpell(TYPE_EQUIP)
end