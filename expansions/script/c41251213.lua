--Sorceress of the Daylilly
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION)
		and (c:IsOriginalAttribute(ATTRIBUTE_FIRE) or Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c:GetOriginalAttribute()))
end
function s.filter(c,at)
	if at&ATTRIBUTE_LIGHT>0 and c:IsAbleToRemove() then
		return true
	elseif at&ATTRIBUTE_DARK>0 and c:IsLocation(LOCATION_MZONE) then
		return true
	elseif at&ATTRIBUTE_WATER>0 and c:IsSpellTrapOnField() then
		return true
	elseif at&ATTRIBUTE_WIND>0 and c:IsAbleToHand() then
		return true
	elseif at&ATTRIBUTE_EARTH>0 and c:IsFacedown() and c:IsAbleToRemove() then
		return true
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local at=e:GetLabel()
		return chkc:IsOnField() and s.filter(chkc,at)
	end
	if chk==0 then
		return e:IsCostChecked() and Duel.CheckReleaseGroup(REASON_COST,tp,s.cfilter,1,nil,tp)
	end
	local tc=Duel.SelectReleaseGroup(REASON_COST,tp,s.cfilter,1,1,nil,tp):GetFirst()
	local att=tc:GetOriginalAttribute()
	local lv=tc:GetLevel()
	Duel.Release(tc,REASON_COST)
	
	local truthtable={}
	local attr=1
	while attr<ATTRIBUTE_ALL do
		if att&attr>0 and (attr==ATTRIBUTE_FIRE or Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,attr)) then
			table.insert(truthtable,true)
		else
			table.insert(truthtable,false)
		end
		attr=attr<<1
	end
	local opt=aux.Option(tp,id,1,table.unpack(truthtable))
	att=2^opt
	e:SetLabel(att)
	
	if att==ATTRIBUTE_FIRE then
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetCategory(CATEGORY_DAMAGE)
		local dam=lv*200
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(dam)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,att)
		local cat=0
		if att&(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH)>0 then
			cat=CATEGORY_REMOVE
		elseif att&(ATTRIBUTE_DARK|ATTRIBUTE_WATER)>0 then
			cat=CATEGORY_DESTROY
		else
			cat=CATEGORY_TOHAND
		end
		e:SetCategory(cat)
		Duel.SetCardOperationInfo(g,cat)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local at=e:GetLabel()
	if at==ATTRIBUTE_FIRE then
		local p,dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,dam,REASON_EFFECT)
	else
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToChain() then return end
		if at&(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH)>0 then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif at&(ATTRIBUTE_DARK|ATTRIBUTE_WATER)>0 then
			Duel.Destroy(tc,REASON_EFFECT)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end