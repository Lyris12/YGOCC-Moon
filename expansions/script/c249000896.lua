--Effect-Magician Kitsune
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000896.initial_effect(c)
	if not c249000896_CopyEffect then
		c249000896_CopyEffect=Card.CopyEffect
		Card.CopyEffect = function(c,code,reset_flag, reset_count)
			c:RegisterFlagEffect(249000894,reset_flag,0,reset_count)
			c249000896_CopyEffect(c,code,reset_flag, reset_count)
		end
	end
	--copy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30312361,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCountLimit(1,249000896)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCondition(c249000896.condition)
	e1:SetCost(c249000896.cost)
	e1:SetTarget(c249000896.target)
	e1:SetOperation(c249000896.operation)
	c:RegisterEffect(e1)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c249000896.condition2)
	e3:SetTarget(c249000896.target2)
	e3:SetOperation(c249000896.operation2)
	c:RegisterEffect(e3)
end
function c249000896.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249000896.costfilter(c)
	return c:IsSetCard(0x2098) and c:IsAbleToRemoveAsCost()
end
function c249000896.costfilter2(c)
	return c:IsSetCard(0x2098) and not c:IsPublic()
end
function c249000896.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000896.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000896.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000896.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000896.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000896.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000896.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000896.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000896.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000896.targetfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(c249000896.targetfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,c)
end
function c249000896.targetfilter2(c)
	return c:GetFlagEffect(2490000894)==0 and c:IsType(TYPE_MONSTER)
end
function c249000896.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000896.targetfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c249000896.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000896.targetfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc==nil then return end
	local g2=Duel.SelectMatchingCard(tp,c249000896.targetfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,1,tc)
	local tc2=g2:GetFirst()
	if tc2==nil then return end
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCardFilter(tp,tc:GetOriginalRace(),OPCODE_ISRACE,TYPE_EFFECT,OPCODE_ISTYPE,OPCODE_AND,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_RITUAL,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND,3027001,OPCODE_ISCODE,OPCODE_OR)
		cc=Duel.CreateToken(tp,ac)
		if ac==3027001 then return end
	until (cc:IsSummonableCard()
		and (cc:GetLevel()==tc:GetLevel() or cc:GetLevel()+1==tc:GetLevel()) and not banned_list_table[ac])
	Duel.ConfirmCards(1-tp,Group.FromCards(cc))
	local e1=Effect.CreateEffect(tc2)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetReset(RESET_EVENT+0x00400000+RESET_PHASE+PHASE_END,1)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(0xFF)
	e1:SetValue(ac)
	tc2:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetLabelObject(e1)
	tc2:RegisterEffect(e2)
	local cid=tc2:CopyEffect(ac,RESET_EVENT+0x00400000+RESET_PHASE+PHASE_END,1)
	local e3=Effect.CreateEffect(tc2)
	e3:SetDescription(aux.Stringid(30312361,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCountLimit(1)
	e3:SetRange(0xFF)
	e3:SetReset(RESET_EVENT+0x00400000+RESET_PHASE+PHASE_END)
	e3:SetLabel(cid)
	e3:SetLabelObject(e2)
	e3:SetOperation(c249000896.rstop)
	tc2:RegisterEffect(e3)
	if not tc2:IsType(TYPE_EFFECT) then
		local e4=e1:Clone()
		e4:SetCode(EFFECT_ADD_TYPE)
		e4:SetValue(TYPE_EFFECT)
		tc2:RegisterEffect(e4)
	end
end
function c249000896.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e1:Reset()
	e2:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c249000896.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c249000896.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249000896.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c249000896.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c249000896.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249000896.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249000896.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end