--Furia Sverdånd
--Scripted by: XGlitchy30
local s,id=GetID()

s.original_property={}
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local p1,p2=e1:GetProperty()
	s.original_property[e1]={p1,p2}
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetLabel(2)
	e2:SetCondition(s.condition1)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
	local p1,p2=e2:GetProperty()
	s.original_property[e2]={p1,p2}
end
function s.cf(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x24d)
end
function s.dfilter(c)
	return s.cf(c) and c:GetAttack()>0
end
function s.spf(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x24d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetProperty(s.original_property[e][1],s.original_property[e][2])
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local prop1,prop2=e:GetProperty()
	local c=e:GetHandler()
	local b1=(e:GetLabel()==1 and Duel.IsExistingTarget(s.dfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2))
	local b2=(e:GetLabel()==2 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
		e:SetProperty(prop1+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET,prop2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g<=0 then return end
		Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,g:GetFirst():GetAttack())
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif e:GetLabel()==2 then
		if rp and rp==1-tp and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
			e:SetProperty(prop1+EFFECT_FLAG_CARD_TARGET,prop2)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
			Duel.SetTargetParam(1)
		else
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
			Duel.SetTargetParam(0)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
			local val=(tc:GetAttack()>=0) and tc:GetAttack() or 0
			if Duel.Damage(p,val,REASON_EFFECT)>0 then
				Duel.BreakEffect()
				Duel.Draw(p,2,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		local v=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spf),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and v==1 then
			local tc=Duel.GetFirstTarget()
			if tc and tc:IsRelateToEffect(e) then
				Duel.BreakEffect()
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end