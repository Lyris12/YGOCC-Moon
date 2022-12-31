--Shomesa, Sunflower  of Rose VINE
function c50031912.initial_effect(c)
		aux.AddOrigEvoluteType(c)
 aux.AddEvoluteProc(c,nil,9,c50031912.mfilter1,3,function(ec,tp,g) return g:FilterCount(c50031912.mfilter2,nil)==1 end)
	c:EnableReviveLimit()
  --spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c50031912.splimit)
	c:RegisterEffect(e1)
  --remove
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50031912,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c50031912.remcon)
	e3:SetCost(c50031912.remcost)
	e3:SetTarget(c50031912.remtg)
	e3:SetOperation(c50031912.remop)
	c:RegisterEffect(e3)
	  local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50031912,1))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c50031912.sumcon)
	e4:SetTarget(c50031912.sumtg)
	e4:SetOperation(c50031912.sumop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e6)
end
function c50031912.splimit(e,se,sp,st)
	return st==SUMMON_TYPE_SPECIAL+388
end
function c50031912.mfilter1(c) return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) end
function c50031912.mfilter2(c) 
return c:IsType(TYPE_NORMAL) end
function c50031912.check1(c,sg,tp)
	return c:IsType(TYPE_NORMAL) and sg:IsExists(c50031912.check2,1,nil,sg)
end

function c50031912.remcon(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388 and e:GetHandler():IsLinkState()
end
function c50031912.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
  if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	 e:GetHandler():RemoveEC(tp,3,REASON_COST)
	--local e1=Effect.CreateEffect(c)
  --  e1:SetType(EFFECT_TYPE_FIELD)
   -- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
   -- e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  --  e1:SetReset(RESET_PHASE+PHASE_END)
  --  e1:SetLabelObject(c)
  --  e1:SetTargetRange(1,0)
  --  e1:SetTarget(c50031912.splimit)
   -- Duel.RegisterEffect(e1,tp)
end
function c50031912.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,0x1e,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0x1e)
end
function c50031912.xxfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function c50031912.remop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	local g3=Duel.GetMatchingGroup(c50031912.xxfilter,tp,0,LOCATION_EXTRA,nil)
	local g4=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	
	local sg=Group.CreateGroup()
	if g1:GetCount()>0 and ((g2:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(50031912,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	if g2:GetCount()>0 and ((sg:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(50031912,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	  if g3:GetCount()>0 and ((sg:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(50031912,3))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:Select(tp,1,1,nil)
		Duel.HintSelection(sg3)
		sg:Merge(sg3)
	end
	if g4:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(50031912,4))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg4=g4:RandomSelect(tp,1)
		sg:Merge(sg4)
	end
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function c50031912.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c50031912.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
function c50031912.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50031912.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(c50031912.filter,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c50031912.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c50031912.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
