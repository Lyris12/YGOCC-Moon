--Divine Draw of Destiny
function c249001102.initial_effect(c)
	aux.AddCodeList(c,10000020,10000000,10000010,30604579,67098114,93483212)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249001102.condition)
	e1:SetCost(c249001102.cost)
	e1:SetTarget(c249001102.target)
	e1:SetOperation(c249001102.activate)
	c:RegisterEffect(e1)
end
function c249001102.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)>=2
end
function c249001102.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetLP(tp) < 4000 then
		Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	else
		Duel.PayLPCost(tp,2000)
	end
end
function c249001102.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001102.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(10000020,10000000,10000010,30604579,67098114,93483212)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c249001102.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c249001102.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsLevelAbove(7) and Duel.IsExistingMatchingCard(c249001102.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,2) then
		local g=Duel.SelectMatchingCard(tp,c249001102.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		local c=e:GetHandler()
		if tc then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_DIVINE)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_DIVINE)
			tc:RegisterEffect(e2)
			if global_card_effect_table[tc] then
				for key,value in pairs(global_card_effect_table[tc]) do
					if value:IsHasType(EFFECT_TYPE_IGNITION) then
						value:SetType(EFFECT_TYPE_QUICK_O)
						value:SetCode(EVENT_FREE_CHAIN)
					end
				end
			end
			if tc:GetOriginalCode()==10000020 then
				local e3=Effect.CreateEffect(tc)
				e3:SetDescription(aux.Stringid(30914564,0))
				e3:SetCategory(CATEGORY_DRAW)
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
				e3:SetCode(EVENT_SPSUMMON_SUCCESS)
				e3:SetTarget(c249001102.drtg)
				e3:SetOperation(c249001102.drop)
				c:RegisterEffect(e3)
				local e4=e3:Clone()
				e3:SetCode(EVENT_SUMMON_SUCCESS)
				tc:RegisterEffect(e4)
				local e5=e3:Clone()
				e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
				tc:RegisterEffect(e5)
			end
			if tc:GetOriginalCode()==10000000 then
				local e3=Effect.CreateEffect(tc)
				e3:SetDescription(1122)
				e3:SetCategory(CATEGORY_DAMAGE)
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetCode(EVENT_BATTLE_DESTROYING)
				e3:SetCondition(aux.bdocon)
				e3:SetTarget(c249001102.damtg)
				e3:SetOperation(c249001102.damop)
				tc:RegisterEffect(e3)		
				local e4=Effect.CreateEffect(tc)
				e4:SetDescription(1122)
				e4:SetCategory(CATEGORY_DAMAGE)
				e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
				e4:SetRange(LOCATION_MZONE)
				e4:SetCode(EVENT_DESTROYED)
				e4:SetCondition(c249001102.damcon)
				e4:SetTarget(c249001102.damtg)
				e4:SetOperation(c249001102.damop)
				tc:RegisterEffect(e4)
			end
			if tc:GetOriginalCode()==10000010 then
				local e3=Effect.CreateEffect(tc)
				e3:SetDescription(1113)
				e3:SetCategory(CATEGORY_ATKCHANGE)
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetCode(EVENT_BATTLE_DESTROYING)
				e3:SetCondition(aux.bdocon)
				e3:SetOperation(c249001102.atkop1)
				tc:RegisterEffect(e3)		
				local e4=Effect.CreateEffect(tc)
				e4:SetDescription(1113)
				e4:SetCategory(CATEGORY_ATKCHANGE)
				e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
				e4:SetRange(LOCATION_MZONE)
				e4:SetCode(EVENT_DESTROYED)
				e4:SetCondition(c249001102.damcon)
				e4:SetOperation(c249001102.atkop2)
				tc:RegisterEffect(e4)
			end
			if tc:GetOriginalCode()==30604579 then
				local e3=Effect.CreateEffect(tc)
				e3:SetDescription(1101)
				e3:SetCategory(CATEGORY_DESTROY)
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
				e3:SetCode(EVENT_SPSUMMON_SUCCESS)
				e3:SetOperation(c249001102.desop)
				c:RegisterEffect(e3)
				local e4=e3:Clone()
				e3:SetCode(EVENT_SUMMON_SUCCESS)
				tc:RegisterEffect(e4)
				local e5=e3:Clone()
				e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
				tc:RegisterEffect(e5)
			end
			if tc:GetOriginalCode()==67098114 then
				local e3=Effect.CreateEffect(tc)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(aux.tgoval)
				tc:RegisterEffect(e3)
			end
			if tc:GetOriginalCode()==93483212 then
				local e3=Effect.CreateEffect(tc)
				e3:SetCategory(CATEGORY_DESTROY)
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
				e3:SetCode(EVENT_SPSUMMON_SUCCESS)
				e3:SetOperation(c249001102.tgop)
				c:RegisterEffect(e3)
				local e4=e3:Clone()
				e3:SetCode(EVENT_SUMMON_SUCCESS)
				tc:RegisterEffect(e4)
				local e5=e3:Clone()
				e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
				tc:RegisterEffect(e5)
			end
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function c249001102.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3-ht)
end
function c249001102.drop(e,tp,eg,ep,ev,re,r,rp)
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht<3 then
		Duel.Draw(tp,3-ht,REASON_EFFECT)
	end
end
function c249001102.damfilter(c,tp)
	return c:GetPreviousControler()==1-tp
end
function c249001102.damcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and re and re:GetHandler()==e:GetHandler() and eg:IsExists(c249001102.damfilter,1,nil,tp)
end
function c249001102.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(4000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,4000)
end
function c249001102.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,4000,REASON_EFFECT)
end
function c249001102.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c:GetBattleTarget():GetPreviousAttackOnField())
		c:RegisterEffect(e1)
	end
end
function c249001102.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=eg:Filter(c249001102.damfilter,nil,tp)
		local val=g:GetSum(Card.GetPreviousAttackOnField,nil)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		c:RegisterEffect(e1)
	end
end
function c249001102.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c249001102.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function c249001102.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp,g)
		Duel.ShuffleHand(1-tp)
	end
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g1:GetCount()>0 then
		Duel.ConfirmCards(tp,g1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=g1:Select(tp,1,1,nil)
		Duel.SendtoGrave(g2,REASON_EFFECT)
	end
end
function c249001102.splimit(e,c)
	return not c:IsRace(RACE_DIVINE)
end