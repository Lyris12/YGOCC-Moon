--[[1 Tuner + 1+ non-Tuner Plant-Type Monsters
If this card is Synchro Summoned: You can target 1 face-up monster your opponent controls; Its ATK 
becomes 0, also, its effects are negated. If you would Synchro Summon a monster using this card as 
a Synchro Material, you can also use Plant-Type Monsters from your hand as the other Materials.]]

function c79854535.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(IsRace,RACE_PLANT),1)
	c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79854535,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c79854535.cond)
	e1:SetTarget(c79854535.target)
	e1:SetOperation(c79854535.operation)
	c:RegisterEffect(e1)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	--e1:SetCondition(c79854535.syncon)
	e1:SetTarget(c79854535.syntg)
	e1:SetValue(1)
	e1:SetOperation(c79854535.synop)
	c:RegisterEffect(e1)
	--hand synchro for double tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	--e3:SetCondition(c79854535.syncon)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	c:RegisterEffect(e3)
end
--atk and effect
function c79854535.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c79854535.filter(c)
	return c:GetPosition(POS_FACEUP) and not (c:GetAttack()==0 and c:IsDisabled())
end
function c79854535.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c79854535.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c79854535.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c79854535.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c79854535.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e3)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e4:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e4)
		end
	end
end
function c79854535.synfilter1(c,syncard,tuner,f)
	return (c:IsFaceup() or (c:IsRace(RACE_PLANT) and c:IsLocation(LOCATION_HAND))) and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c))
end
function c79854535.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=(ct<maxc and mg:IsExists(c79854535.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
		or (ct>=minc and c79854535.syngoal(g,tp,lv,syncard))
	g:RemoveCard(c)
	return res
end
function c79854535.syngoal(g,tp,lv,syncard)
	local ct=g:GetCount()
	return g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard) and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
end
function c79854535.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=0 then return false end
	local g=Group.FromCards(e:GetHandler())
	local mg=Duel.GetMatchingGroup(c79854535.synfilter1,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,c,syncard,c,f)
	return mg:IsExists(c79854535.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
function c79854535.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(e:GetHandler())
	local mg=Duel.GetMatchingGroup(c79854535.synfilter1,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(c79854535.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c79854535.syngoal(g,tp,lv,syncard) then
			if not Duel.SelectYesNo(tp,210) then break end
			minct=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	Duel.SetSynchroMaterial(g)
end