--created by Hoshi, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure2(c,aux.FilterBoolFunction(Card.IsSetCard,0xcda),aux.FilterBoolFunction(Card.IsCode,id-12))
	aux.AddCodeList(c,id-12)
	c:SetUniqueOnField(1,0,id)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetValue(id-12)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(cid.matcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetHandler():GetMaterial():IsExists(Card.IsCode,1,nil,id-12) end)
	e2:SetTarget(cid.regtg)
	e2:SetOperation(cid.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetTarget(cid.eqtg)
	e4:SetOperation(cid.eqop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e5:SetCondition(cid.negcon)
	e5:SetCost(cid.negcost)
	e5:SetTarget(cid.negtg)
	e5:SetOperation(cid.negop)
	c:RegisterEffect(e5)
end
function cid.matcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsCode,nil,id-12):GetFirst():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
function cid.filter(c)
	return c:IsSetCard(0xcda) and c:GetPreviousEquipTarget():IsCode(id-12)
end
function cid.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject():Filter(cid.filter,nil)
	local qg=g:Clone()
	if chk==0 then return true end
	Duel.SetTargetCard(qg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,qg,#qg,0,0)
	local tg=qg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #tg>0 then Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,#tg,0,0) end
end
function cid.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)~=#g or Duel.GetLocationCount(tp,LOCATION_SZONE)<#g then return end
	for tc in aux.Next(g) do
		if Duel.Equip(tp,tc,c,true,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(function(ef,cc) return cc==c end)
			tc:RegisterEffect(e1)
		end
	end
	Duel.EquipComplete()
end
function cid.eqfilter(c)
	return c:IsSetCard(0xcda) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not ec or not Duel.Equip(tp,ec,c,true) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(ef,cc) return cc==c end)
	ec:RegisterEffect(e1)
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
		and c:GetEquipGroup():IsExists(aux.AND(Card.IsFaceup,Card.IsSetCard),1,nil,0xcda)
end
function cid.negfilter(c,e)
	local tc=c:GetEquipTarget()
	return c:IsFaceup() and c:IsSetCard(0xcda) and tc and tc==e:GetHandler() and c:IsType(TYPE_EQUIP) and c:IsAbleToRemoveAsCost()
end
function cid.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.negfilter,tp,LOCATION_ONFIELD,0,2,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,cid.negfilter,tp,LOCATION_ONFIELD,0,2,2,nil,e),POS_FACEUP,REASON_COST)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbcon(tp,re) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
