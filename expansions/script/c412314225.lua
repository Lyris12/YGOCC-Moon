--created by Jake, coded by Lyris, art from "The Sanctuary in the Sky"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e3:SetValue(0)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(cid.cost)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetDescription(1109)
	e4:SetLabel(1)
	e4:SetTarget(cid.dthtg)
	e4:SetOperation(cid.dthop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(cid.cost)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(1118)
	e5:SetLabel(2)
	e5:SetTarget(cid.sptg)
	e5:SetOperation(cid.spop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e6:SetCost(cid.cost)
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetDescription(1105)
	e6:SetLabel(3)
	e6:SetTarget(cid.tdtg)
	e6:SetOperation(cid.tdop)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e7:SetCost(cid.cost)
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetDescription(1104)
	e7:SetLabel(4)
	e7:SetTarget(cid.gthtg)
	e7:SetOperation(cid.gthop)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e8:SetCost(cid.cost)
	e8:SetDescription(1101)
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetLabel(5)
	e8:SetTarget(cid.mdestg)
	e8:SetOperation(cid.mdesop)
	c:RegisterEffect(e8)
	local e0=e8:Clone()
	e0:SetDescription(1100)
	e0:SetTarget(cid.sdestg)
	e0:SetOperation(cid.sdesop)
	c:RegisterEffect(e0)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_DESTROYED)
	e9:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e9:SetCategory(CATEGORY_DRAW)
	e9:SetTarget(cid.drtg)
	e9:SetOperation(cid.drop)
	c:RegisterEffect(e9)
end
cid.material_setcode=0x613
function cid.damcon(e,tp,eg,ep)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ep==tp and (a:IsRace(RACE_WARRIOR) and a:GetEffectCount(EFFECT_AVOID_BATTLE_DAMAGE)==1
		or (d and d:IsRace(RACE_WARRIOR) and d:GetEffectCount(EFFECT_AVOID_BATTLE_DAMAGE)==1))
end
function cid.damop(e,tp)
	Duel.ChangeBattleDamage(tp,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESET_TOFIELD+RESET_TURN_SET,0,1)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)>=ct end
	Duel.DiscardHand(tp,Card.IsDiscardable,ct,ct,REASON_COST+REASON_DISCARD)
	local n=e:GetHandler():GetFlagEffectLabel(id)
	if not n then
		e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESET_TOFIELD+RESET_TURN_SET,0,1,1)
	else e:GetHandler():SetFlagEffectLabel(id,n+1) end
end
function cid.dthfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x613) and c:IsAbleToHand()
end
function cid.dthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.dthop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.dthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x613) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.tdfilter(c)
	return c:IsSetCard(0x613) and c:IsAbleToDeck()
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
function cid.gthfilter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x613) or aux.IsMaterialListSetCard(c,0x613)) and c:IsAbleToHand()
end
function cid.gthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.gthfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cid.gthop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.gthfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.mdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function cid.mdesop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function cid.sdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function cid.sdesop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.Destroy(sg,REASON_EFFECT)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
