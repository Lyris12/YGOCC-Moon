--created & coded by Lyris, art at https://gnosticwarrior.com/wp-content/uploads/2016/04/Quote-in-the-beginning-was-the-word.jpg
--スターダスト・ミディアム
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_STARDUST_TOKEN,0xa3,0x4011,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_STARDUST_TOKEN,0xa3,0x4011,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) then return end
	local c=e:GetHandler()
	local token=Duel.CreateToken(tp,CARD_STARDUST_TOKEN)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsType),tp,LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP):Filter(Card.IsAbleToRemove,nil)
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)==0 or e:GetRange()~=LOCATION_HAND or #g==0
		or not Duel.SelectEffectYesNo(tp,c) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tg=g:Select(tp,1,99,nil)
	if #tg>0 then Duel.BreakEffect() end
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(tg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED))
	token:RegisterEffect(e1)
end
