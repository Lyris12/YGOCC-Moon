--Azrael, The Origin Dragon
--created by Ace, coded by Lyris

local s,id=GetID()
function s.initial_effect(c)
	--stats
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORIES_ATKDEF)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetBattleTarget()~=nil end)
	e0:SetTarget(s.atktg)
	e0:SetOperation(s.atkop)
	c:RegisterEffect(e0)
	--tokens
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&(REASON_BATTLE|REASON_EFFECT)~=0 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local d=c:GetBattleTarget()
	if not d then return end
	local dp,dl=d:GetControler(),d:GetLocation()
	Duel.SetTargetCard(d)
	local atk,def,val=-2,-2,-2
	if d and d:IsFaceup() and d:HasAttack() and d:HasDefense() then
		atk,def=d:GetAttack(),d:GetDefense()
		val=math.abs(atk-def)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,d,1,dp,dl,atk)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,d,1,dp,dl,def)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),val)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:HasAttack() and tc:HasDefense() then
		local atk,def=tc:GetAttack(),tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(def)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		if c:IsRelateToChain() and c:IsFaceup() and c:HasAttack() and not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) then
			Duel.AdjustAll()
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,2)
			e2:SetValue(math.abs(tc:GetAttack()-tc:GetDefense()))
			c:RegisterEffect(e2)
		end
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DRAGON_EGG,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_DRAGON,ATTRIBUTE_FIRE) then
		return
	end
	local c=e:GetHandler()
	for i=0,1 do
		local token=Duel.CreateToken(tp,TOKEN_DRAGON_EGG)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetValue(s.matlim)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		token:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end
function s.matlim(e,c)
	if not c then return false end
	return not c:IsSetCard(ARCHE_ORIGIN_DRAGON)
end

function s.tdfilter(c,tp)
	return c:IsCode(TOKEN_DRAGON_EGG) and (c:IsControler(tp) or c:IsFaceup())
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.tdfilter,nil,tp)
	if chk==0 then return #rg>=2 and rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	aux.UseExtraReleaseCount(g,tp)
	Duel.Release(g,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
