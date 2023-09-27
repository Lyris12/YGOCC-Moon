--Despaircaster Ward
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--banish
	local e0=Effect.CreateEffect(c)
	e0:Desc(2)
	e0:SetCategory(CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	e0:SetReset(RESET_PHASE|PHASE_END)
	--excavate
	local ex=aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_QUICK_O,0,ARCHE_DESPAIRCASTER,e0,CATEGORY_REMOVE)
	e0:SetLabelObject(ex)
	--equip
	aux.AddAircasterEquipEffect(c,1)
	--wipe backrow
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.con)
	e1:SetCost(aux.ToGraveSelfCost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local eid=e:GetLabel()
	local ct=eg:FilterCount(s.cfilter,nil,eid,e:GetLabelObject())
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2*ct,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	local g=Duel.GetDecktopGroup(1-tp,2*ct)
	local sg=g:Filter(Card.IsAbleToRemove,nil)
	if #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.Banish(sg)
	end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSpell(TYPE_EQUIP) then return false end
	local eqc=c:GetEquipTarget()
	if not eqc then return false end
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==eqc and bc:IsPreviousControler(1-tp)
end
function s.tfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		return #g>0 and not g:IsExists(aux.NOT(s.tfilter),1,nil,tp)
	end
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil):Filter(s.tfilter,nil,tp)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end