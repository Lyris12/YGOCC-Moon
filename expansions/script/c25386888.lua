--created by Jake, coded by Lyris
--Steinitz's En Passant
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.handcon)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	e5:HOPT(true)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetCondition(aux.exccon)
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,aux.GetColumn(c,tp))
end
function s.filter(c,col)
	return s.sfilter(c) and c:GetBattledGroupCount()<1 and c:GetSequence()==col
end
function s.condition(e,tp,eg,ep)
	local tg=eg:Filter(s.cfilter,nil,tp)
	e:SetLabelObject(tg:GetFirst())
	return #tg==1
end
function s.target(e,tp,_,_,_,_,_,_,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc~=nil end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x63d0)
end
function s.activate(e,tp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or c:IsControler(tp) or Duel.Destroy(tc,REASON_EFFECT)<1
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_MZONE,0,nil)
	if #g<1 or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sg=g:Select(tp,1,1,nil)
	Duel.HintSelection(sg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(sg:GetFirst(),math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
end
function s.hfilter(c)
	return s.sfilter(c) and c:IsLocation(LOCATION_MZONE) and c:GetEquipCount()<1
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.hfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.qfilter(c,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x63d0) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.qfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not (ec and Duel.Equip(tp,ec,tc)) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlim)
	ec:RegisterEffect(e1)
end
function s.eqlim(e,c)
	return c==e:GetLabelObject()
end
